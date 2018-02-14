require 'fileutils'
require 'yaml'
require 'redcarpet'
require 'redcarpet/render_strip'

module Shaf
  class ApiDocTask
    include Rake::DSL

    attr_accessor :directory, :html_output, :yaml_output

    def initialize
      yield self if block_given?
      define_tasks
    end

    def define_tasks
      namespace :doc do
        desc "Generate API documentation"
        task :generate do
          files = Dir.glob(File.join(@directory, "*.rb"))
          files.each do |file|
            read_file file do |doc|
              next unless doc.has_enough_info?
              write_html doc
              write_yaml doc
            end
          end
        end

        desc "Remove generated documentation"
        task :clean do
          [
            Dir.glob(File.join(@yaml_output, "*.yml")),
            Dir.glob(File.join(@html_output, "*.html"))
          ].flatten.each do |file|
            File.unlink file
          end
        end
      end
    end


    def read_file(file)
      doc = Document.new
      comment = Comment.new

      File.readlines(file).each do |line|
        next if empty_line?(line)

        if c = comment(line)
          comment << c
          next
        end

        if model = model(line)
          doc.model = model
        elsif serializer_class = serializer_class(line)
          doc.serializer_class = serializer_class
        elsif policy = policy(line)
          doc.policy = policy
        elsif attr = attribute(line)
          doc.attribute(attr, comment)
        elsif rel = link(line)
          doc.link(rel, comment)
        elsif rel = curie(line)
          doc.curie(rel, comment)
        elsif name = embed(line)
          doc.embedded(name, comment)
        end

        comment = Comment.new
      end

      return doc unless block_given?
      yield doc
    end

    def empty_line?(line)
      true if line[/\A[#\s*]*\Z/]
    end

    def serializer_class(line)
      line[/\A\s*class\s*(\w+)\Z/, 1]
    end

    def model(line)
      line[/\A\s*model\s*(?:::)?(\w+)/, 1]
    end

    def policy(line)
      line[/\A\s*policy\s*(?:::)?(\w+)/, 1]
    end

    def comment(line)
      line[/\A\s*#(.*)/, 1]
    end

    def attribute(line)
      line[/\A\s*attribute[^s]\s*\(?\s*:(\w+)/, 1]
    end

    def link(line)
      line[/\A\s*link\s*\(?\s*:'?([-:\w]+)'?/, 1]
    end

    def curie(line)
      line[/\A\s*curie\s*\(?\s*:'?([-\w]+)'?/, 1]
    end

    def embed(line)
      line[/\A\s*embed\s*\(?\s*:'?([-:\w]+)'?/, 1]
    end

    def write_html(doc)
      FileUtils.mkdir_p(@html_output) unless Dir.exist? @html_output
      File.open(File.join(@html_output, "#{doc.model.downcase}.html"), "w") do |file|
        file.write(doc.to_markdown)
      end
    end

    def write_yaml(doc)
      FileUtils.mkdir_p(@yaml_output) unless Dir.exist? @yaml_output
      File.open(File.join(@yaml_output, "#{doc.model.downcase}.yml"), "w") do |file|
        file.write(doc.generate_yaml!)
      end
    end

  end

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
      @links[rel] = comment unless comment.empty?
    end

    def curie(rel, comment)
      @curies[rel] = comment unless comment.empty?
    end

    def embedded(name, comment)
      @embeds[name] = comment unless comment.empty?
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
      hash[:policy] = renderer.render(@md[:policy]).chomp if @md[:policy]

      [:attributes, :curies, :links, :embeds].each do |key|
        hash[key] = @md[key].map { |k, v| [k.to_sym, renderer.render(v).chomp] }.to_h
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

    private
    
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

  class Comment
    def initialize
      @indent = 0
      @comment = ""
    end

    def to_s
      @comment
    end

    def empty?
      @comment.empty?
    end

    def <<(line)
      @indent = line[/\A\s*/].size if empty?
      @comment << "\n#{extract(line)}"
    end

    def extract(line)
      line.sub(%r(\A\s{#{@indent}}), "")
    end
  end
end
