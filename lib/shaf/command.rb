module Shaf
  module Command
    class Registry
      @commands = []

      def self.register(clazz)
        @commands << clazz
      end

      def self.lookup(str)
        @commands.detect do |clazz|
          return unless clazz.respond_to? :identified_by
          pattern = clazz.identified_by or return
          pattern = %r(\A#{pattern}\Z) if pattern.is_a? String
          str.match(pattern)
        end
      end

      def self.usage
        @commands.map(&:usage).compact
      end
    end

    class Factory
      def self.create(str, *args)
        clazz = Registry.lookup(str)
        raise NotFoundError.new(str) unless clazz
        clazz.new(*args)
      end
    end

    class NotFoundError < StandardError
      def initialize(cmd)
        super(%Q(Command '#{cmd}' is not supported))
      end
    end

    class ArgumentError < StandardError; end

    class BaseCommand

      attr_reader :args

      def self.inherited(child)
        Registry.register(child)
      end

      def self.usage
        nil
      end

      def initialize(*args)
        @args = args
      end
    end

    Dir[File.join(__dir__, 'command', '*.rb')].each { |file| require file }
  end
end
