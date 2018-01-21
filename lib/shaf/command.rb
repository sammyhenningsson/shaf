require 'shaf/registrable'

module Shaf
  module Command
    class Registry
      extend Registrable
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

    class Base

      attr_reader :args

      class << self
        def inherited(child)
          Registry.register(child)
        end

        def identifier(*ids)
          @identifiers = ids.map(&:to_s)
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
  end
end

Dir[File.join(__dir__, 'command', '*.rb')].each { |file| require file }
