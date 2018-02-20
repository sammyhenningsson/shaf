require 'shaf/api_doc/document'

module Shaf
  module ApiDoc
    class Task
      include Rake::DSL

      attr_accessor :document_class, :source_dir, :html_output_dir, :yaml_output_dir

      def initialize
        yield self if block_given?
        validate_attributes!
        @document_class ||= Document
        define_tasks
      end

      def validate_attributes!
        raise "source_dir must be set!" unless source_dir
        raise "html_output_dir must be configured in ApiDocTask" unless html_output_dir
        raise "yaml_output_dir must be configured in ApiDocTask" unless yaml_output_dir
      end

      def define_tasks
        namespace :doc do
          desc "Generate API documentation"
          task :generate do
            files = Dir.glob(File.join(source_dir, "*.rb"))
            files.each do |file|
              read_file file do |doc|
                next unless doc.has_enough_info?
                doc.write_html @html_output_dir
                doc.write_yaml @yaml_output_dir
              end
            end
          end

          desc "Remove generated documentation"
          task :clean do
            [
              Dir.glob(File.join(@yaml_output_dir, "*.yml")),
              Dir.glob(File.join(@html_output_dir, "*.html"))
            ].flatten.each do |file|
              File.unlink file
            end
          end
        end
      end

      def read_file(file)
        doc = document_class.new
        comment = Comment.new

        File.readlines(file).each do |line|
          next if empty_line?(line)

          if c = comment(line)
            comment << c
            next
          end

          parse_line(line, doc, comment)
          comment = Comment.new
        end

        return doc unless block_given?
        yield doc
      end

      def parse_line(line, doc, comment)
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
    end
  end
end
