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
          return unless clazz.respond_to? :identified_by
          pattern = clazz.identified_by or return
          pattern = %r(\A#{pattern}\Z) if pattern.is_a? String
          str.match(pattern)
        end
      end

      def self.usage
        @generators.map(&:usage).compact
      end
    end

    class Factory
      def self.create(str, *args)
        clazz = Registry.lookup(str)
        raise NotFoundError.new(%Q(Generator '#{str}' is not supported)) unless clazz
        clazz.new(*args)
      end
    end

    class NotFoundError < StandardError; end

    class BaseGenerator
      attr_reader :args

      def self.inherited(child)
        Registry.register(child)
      end

      def self.usage
        nil
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
