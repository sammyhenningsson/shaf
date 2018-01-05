require 'fileutils'

module Shaf
  module Generator
    class Registry
      @generators = []

      def self.register(clazz)
        @generators << clazz
      end

      def self.lookup(str)
        @generators.detect do |clazz|
          pattern = clazz.instance_eval { @id }
          return if pattern.nil? || pattern.empty?
          pattern = %r(\A#{pattern}\Z) if pattern.is_a? String
          str.match(pattern)
        end
      end

      def self.usage
        @generators.map {|gen| gen.instance_eval { @usage } }.compact
      end
    end

    class Factory
      def self.create(str, *args)
        clazz = Registry.lookup(str)
        return clazz.new(*args) if clazz
        raise Command::NotFoundError, %Q(Generator '#{str}' is not supported)
      end
    end

    class BaseGenerator
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
    end

    Dir[File.join(__dir__, 'generator', '*.rb')].each do |file|
      require file
    end
  end
end
