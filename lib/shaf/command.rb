require 'optparse'
require 'shaf/utils'
require 'shaf/registrable_factory'

module Shaf
  module Command

    class ArgumentError < StandardError; end

    class Factory
      extend RegistrableFactory
    end

    class Base
      include Utils

      attr_reader :args, :options

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

        def exit_with_error(msg, status)
          STDERR.puts msg
          exit status
        end

        def options(option_parser, options); end
      end

      def initialize(*args)
        @args = args.dup
        @options = {}
        parse_options!
      end

      private

      def parse_options!
        parser = OptionParser.new
        self.class.options(parser, @options)
        parser.parse!(@args)
      end
    end
  end
end

require 'shaf/command/new'
require 'shaf/command/server'
require 'shaf/command/console'
require 'shaf/command/generate'
