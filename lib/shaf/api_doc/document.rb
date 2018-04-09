require 'fileutils'
require 'yaml'
require 'redcarpet'
require 'redcarpet/render_strip'

module Shaf
  module ApiDoc
    class Document
      attr_writer :model
      attr_accessor :serializer_class, :policy, :attributes, :links, :curies, :embeds

      def initialize
        @model = nil
        @serializer_class = nil
        @policy = nil
        @attributes = {}
        @links = {}
        @curies = {}
        @embeds = {}
        @md = {}
      end

      def model
        @model || @serializer_class && @serializer_class.sub("Serializer", "")
      end

      def attribute(attr, comment)
        @attributes[attr] = comment unless comment.empty?
      end

      def link(rel, comment)
        @links[strip_curie(rel)] = comment unless comment.empty?
      end

      def curie(rel, comment)
        @curies[rel] = comment unless comment.empty?
      end

      def embedded(name, comment)
        @embeds[strip_curie(name)] = comment unless comment.empty?
      end

      def has_enough_info?
        return false unless model
        attributes.merge(links).merge(curies).any?
      end

      def generate_markdown!
        return @md unless @md.empty?

        generate_title!
        generate_policy!
        generate_section!(key: :attributes, heading: "Attributes")
        generate_section!(key: :curies, heading: "Curies", sub_title: "rel")
        generate_section!(key: :links, heading: "Links", sub_title: "rel")
        generate_section!(key: :embeds, heading: "Embedded resources", sub_title: "rel")
        @md[:doc]
      end

      def generate_yaml!
        generate_markdown!
        renderer = Redcarpet::Markdown.new(Redcarpet::Render::StripDown)

        hash = {}
        hash['policy'] = renderer.render(@md[:policy]).chomp if @md[:policy]

        [:attributes, :curies, :links, :embeds].each do |key|
          hash[key.to_s] = @md[key].map { |k, v| [k.to_s, renderer.render(v).chomp] }.to_h
        end
        hash.to_yaml
      end

      def to_markdown
        # For some reason redcarpet don't like to surround my markdown code blocks
        # with <pre> tags, so let's fix that here.
        options = {autolink: true, fenced_code_blocks: true}
        markdown = Redcarpet::Markdown.new(Redcarpet::Render::HTML, options)
        html = markdown.render(generate_markdown!)
        html.gsub!("<code>", "<pre><code>")
        html.gsub!("</code>", "</code></pre>")
        html
      end

      def write_html(output)
        FileUtils.mkdir_p(output) unless Dir.exist? output
        File.open(File.join(output, "#{model.downcase}.html"), "w") do |file|
          file.write(to_markdown)
        end
      end

      def write_yaml(output)
        FileUtils.mkdir_p(output) unless Dir.exist? output
        File.open(File.join(output, "#{model.downcase}.yml"), "w") do |file|
          file.write(generate_yaml!)
        end
      end


      private

      def strip_curie(rel)
        rel.split(':', 2)[1] || rel
      end

      def generate_title!
        @md[:doc] = "##%s\n" % model.capitalize
        @md[:title] = model.capitalize
      end

      def generate_policy!
        return if policy.nil?
        @md[:doc] << "###Policy\n#{policy}\n"
        @md[:policy] = policy
      end

      def generate_section!(key:, heading:, sub_title: "")
        list = send(key)
        @md[:doc] << "####{heading}\n"
        @md[key] = {}
        if list.empty?
          @md[:doc] << "This resource does not have any documented #{heading.downcase}\n"
        else
          sub_title << ": " unless sub_title.empty?
          list.each do |name, comment|
            @md[:doc] << "#######{sub_title}#{name.gsub('_', '-')}\n#{comment.to_s}\n"
            @md[key][name] = comment.to_s.chomp
          end
        end
      end
    end
  end
end
