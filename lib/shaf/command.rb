module Shaf
  module Command
    class Registry
      @commands = []

      def self.register(clazz)
        @commands << clazz
      end

      def self.lookup(str)
        @commands.detect do |clazz|
          pattern = clazz.instance_eval { @id }
          return if pattern.nil? || pattern.empty?
          pattern = %r(\A#{pattern}\Z) if pattern.is_a? String
          str.match(pattern)
        end
      end

      def self.usage
        @commands.map {|cmd| cmd.instance_eval { @usage } }.compact
      end
    end

    class Factory
      def self.create(str, *args)
        clazz = Registry.lookup(str)
        raise NotFoundError.new(%Q(Command '#{str}' is not supported)) unless clazz
        clazz.new(*args)
      end
    end

    class NotFoundError < StandardError; end
    class ArgumentError < StandardError; end

    class BaseCommand

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

        def description(str)
          @description = str
        end
      end

      def initialize(*args)
        @args = args.dup
      end
    end

    Dir[File.join(__dir__, 'command', '*.rb')].each { |file| require file }
  end
end
