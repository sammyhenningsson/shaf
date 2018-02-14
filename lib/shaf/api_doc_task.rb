require 'redcarpet'
require 'redcarpet/render_strip'

module Shaf
  class ApiDocTask
    include Rake::DSL

    attr_accessor :directory, :html_output, :text_output

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
              write_text doc
            end
          end
        end

        desc "Remove generated documentation"
        task :clean do
          [
            Dir.glob(File.join(@text_output, "*.txt")),
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
        elsif policy = policy(line)
          doc.policy = policy
        elsif attr = attribute(line)
          doc.attribute(attr, comment)
        elsif rel = link(line)
          doc.link(rel, comment)
        elsif rel = curie(line)
          doc.curie(rel, comment)
        end

        comment = Comment.new
      end

      return doc unless block_given?
      yield doc
    end

    def empty_line?(line)
      true if line[/\A[#\s*]*\Z/]
    end

    def model(line)
      line[/\A\s*model\s*(?:::)?(\w*)/, 1]
    end

    def policy(line)
      line[/\A\s*policy\s*(?:::)?(\w*)/, 1]
    end

    def comment(line)
      line[/\A\s*#(.*)/, 1]
    end

    def attribute(line)
      line[/\A\s*attribute[^s]\s*\(?\s*:(\w*)/, 1]
    end

    def link(line)
      line[/\A\s*link\s*\(?\s*:'?([-\w]*)'?/, 1]
    end

    def curie(line)
      line[/\A\s*curie\s*\(?\s*:'?([-\w]*)'?/, 1]
    end

    def write_html(doc)
      Dir.mkdir(@html_output) unless Dir.exist? @html_output
      File.open(File.join(@html_output, "#{doc.model}.html"), "w") do |file|
        file.write markdown2html(doc)
      end
    end

    def write_text(doc)
      Dir.mkdir(@text_output) unless Dir.exist? @text_output
      markdown = Redcarpet::Markdown.new(Redcarpet::Render::StripDown)
      File.open(File.join(@text_output, "#{doc.model}.txt"), "w") do |file|
        file.write markdown.render(doc.generate_markdown)
      end
    end

    # For some reason redcarpet don't like to surround my markdown code blocks
    # with <pre> tags, so let's fix that here.
    def markdown2html(doc)
      options = {autolink: true, fenced_code_blocks: true}
      markdown = Redcarpet::Markdown.new(Redcarpet::Render::HTML, options)
      html = markdown.render(doc.generate_markdown)
      html.gsub!("<code>", "<pre><code>")
      html.gsub!("</code>", "</code></pre>")
      html
    end
  end

  class Document
    attr_accessor :model, :policy, :attributes, :links, :curies

    def initialize
      @model = ""
      @policy = ""
      @attributes = {}
      @links = {}
      @curies = {}
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

    def has_enough_info?
      return false if model.empty?
      attributes.merge(links).merge(curies).any?
    end

    def generate_markdown
      return @md if defined? @md

      gen_title!
      gen_policy!
      gen_attributes!
      gen_links!
      gen_embedded!
      @md
    end

    private
    
    def gen_title!
      @md = "##%s\n" % model.capitalize
    end

    def gen_policy!
      return if policy.empty?
      @md << "###Policy\n"
      @md << policy + "\n"
    end

    def gen_attributes!
      @md << "###Attributes\n"
      if attributes.empty?
        @md << "This resource does not have any documented attributes\n"
      else
        attributes.each do |attr, comment|
          @md << "######{attr.gsub('_', '-')}\n"
          @md << comment.to_s + "\n"
        end
      end
    end

    def gen_links!
      @md << "###Links\n"
      if links.empty?
        @md << "This resource does not have any documented links\n"
      else
        links.each do |rel, comment|
          @md << "#####rel: #{rel.gsub('_', '-')}\n"
          @md << comment.to_s + "\n"
        end
      end
    end

    def gen_embedded!
      # TODO
    end

  end

  class Comment
    def initialize
      @indent = 0
      @md = ""
    end

    def to_s
      @md
    end

    def empty?
      @md.empty?
    end

    def <<(line)
      @indent = line[/\A\s*/].size if empty?
      @md << extract(line)
    end

    def extract(line)
      line.sub(%r(/\A\s{#{@indent}}/), "")
    end
  end
end
