require 'shaf/registrable_factory'

module Shaf
  module Command

    class ArgumentError < StandardError; end

    class Factory
      extend RegistrableFactory
    end

    class Base

      attr_reader :args

      class << self
        def inherited(child)
          Factory.register(child)
        end

        def identifier(*ids)
          @identifiers = ids.flatten
        end

        def usage(str = nil, &block)
          @usage = str || block
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
