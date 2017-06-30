require 'redcarpet'
require 'redcarpet/render_strip'

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
          read_file file do
            generate_doc
            write_html
            write_text
          end
        end
      end

      desc "Remove genrated documentation"
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
    return unless block_given?

    @doc = Document.new
    comment = Comment.new

    File.readlines(file).each do |line|
      next if empty_line?(line)

      if c = comment(line)
        comment << c
        next
      end

      if model = model(line)
        @doc.model = model
      elsif policy = policy(line)
        @doc.policy = policy
      elsif attr = attribute(line)
        @doc.attribute(attr, comment)
      elsif rel = link(line)
        @doc.link(rel, comment)
      elsif rel = curie(line)
        @doc.curie(rel, comment)
      end

      comment = Comment.new
    end

    yield if @doc.has_enough_info?
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

  def generate_doc
    @md_doc = "##%s\n" % @doc.model.capitalize

    unless @doc.policy.empty?
      @md_doc << "####Policy\n"
      @md_doc << @doc.policy + "\n"
    end

    @md_doc << "####Attributes\n"
    if @doc.attributes.empty?
      @md_doc << "This resource does not have any documented attributes\n"
    else
      @doc.attributes.each do |attr, comment|
        @md_doc << "######{attr.gsub('_', '-')}\n"
        @md_doc << comment.to_s + "\n"
      end
    end

    @md_doc << "####Links\n"
    if @doc.links.empty?
      @md_doc << "This resource does not have any documented links\n"
    else
      @doc.links.each do |rel, comment|
        @md_doc << "#####rel: #{rel.gsub('_', '-')}\n"
        @md_doc << comment.to_s + "\n"
      end
    end
  end

  def write_html
    Dir.mkdir(@html_output) unless Dir.exist? @html_output
    File.open(File.join(@html_output, "#{@doc.model}.html"), "w") do |file|
      file.write markdown2html
    end
  end

  def write_text
    Dir.mkdir(@text_output) unless Dir.exist? @text_output
    markdown = Redcarpet::Markdown.new(Redcarpet::Render::StripDown)
    File.open(File.join(@text_output, "#{@doc.model}.txt"), "w") do |file|
      file.write markdown.render(@md_doc)
    end
  end

  # For some reason redcarpet don't like to surround my markdown code blocks
  # with <pre> tags, so let's fix that here.
  def markdown2html
    options = {autolink: true, fenced_code_blocks: true}
    markdown = Redcarpet::Markdown.new(Redcarpet::Render::HTML, options)
    md = markdown.render(@md_doc)
    md.gsub!("<code>", "<pre><code>")
    md.gsub!("</code>", "</code></pre>")
    md
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
    !(attributes.empty? && links.empty? && curies.empty? && policy.empty?)
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
