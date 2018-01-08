require 'fileutils'
require 'erb'
require 'ostruct'
require 'shaf/registrable'

module Shaf
  module Generator
    class Registry
      extend Registrable
    end

    class Factory
      def self.create(str, *args)
        clazz = Registry.lookup(str)
        return clazz.new(*args) if clazz
        raise Command::NotFoundError, %Q(Generator '#{str}' is not supported)
      end
    end

    class Base
      attr_reader :args

      class << self
        def inherited(child)
          Registry.register(child)
        end

        def identifier(id)
          @id = id.to_s
        end

        def usage(str)
          @usage = str
        end
      end

      def initialize(*args)
        @args = args.dup
      end

      def template_dir
        File.expand_path('../generator/templates', __FILE__)
      end

      def target(template, locals = {})
        template.sub("#{template_dir}/", "")
      end

      def read_template(file, directory = nil)
        directory ||= template_dir
        filename = File.join(directory, file)
        filename << ".erb" unless filename.end_with?(".erb")
        File.read(filename)
      end

      def render(template, locals = {})
        str = read_template(template)
        locals[:changes] ||= []
        b = OpenStruct.new(locals).instance_eval { binding }
        ERB.new(str).result(b)
      rescue SystemCallError => e
        puts "Failed to render template #{template}: #{e.message}"
        raise
      end

      def write_output(file, content)
        dir = File.dirname(file)
        FileUtils.mkdir_p(dir) unless Dir.exist?(dir)
        File.write(file, content)
        puts "Adding file: #{file}"
      end
    end
  end
end

Dir[File.join(__dir__, 'generator', '*.rb')].each { |file| require file }
