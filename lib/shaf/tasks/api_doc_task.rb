module Shaf
  module Tasks
    class ApiDocTask
      include Rake::DSL

      attr_accessor :document_class, :source_dir, :html_output_dir, :yaml_output_dir

      def initialize
        return show_deprecation_message if RUBY_VERSION >= '3.0.0'

        require 'shaf/api_doc/document'
        require 'shaf/api_doc/comment'

        yield self if block_given?
        validate_attributes!
        @document_class ||= ApiDoc::Document
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
            show_deprecation_message

            files = Dir.glob(File.join(source_dir, "*.rb"))
            files.each do |file|
              read_file file do |doc|
                next unless doc.valid?
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

      def show_deprecation_message
        ruby3_msg = <<~RUBY3 if RUBY_VERSION >= '3.0.0'

          Due to errors with the Redcarpet gem it's not possible to use this deprecated rake task with Ruby >= 3.0.0
          If you need to continue with this task please use an older version of Ruby.
        RUBY3

        puts <<~MSG
          This way of generating documentation is DEPRECATED.#{ruby3_msg}

          Please move the documentation comments into profiles instead and run:
          shaf generate doc
          See https://github.com/sammyhenningsson/shaf/blob/main/doc/DOCUMENTATION.md for more info

        MSG
      end

      def read_file(file)
        doc = document_class.new
        comment = ApiDoc::Comment.new

        File.readlines(file).each do |line|
          next if empty_line?(line)

          if c = comment(line)
            comment << c
            next
          end

          parse_line(line, doc, comment)
          comment = ApiDoc::Comment.new
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
        line[/\A\s*attribute\s+\(?:(\w+)/, 1]
      end

      def link(line)
        line[/\A\s*link\s+\(?:?['"]?([-:\w]+)['"]?/, 1]
      end

      def curie(line)
        line[/\A\s*curie\s+\(?:'?([-\w]+)'?/, 1]
      end

      def embed(line)
        line[/\A\s*embed\s+\(?:'?([-:\w]+)'?/, 1]
      end
    end
  end
end
