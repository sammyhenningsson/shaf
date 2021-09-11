require 'optparse'
require 'shaf/utils'

module Shaf
  module Command
    class ArgumentError < CommandError; end

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

        def identified_by
          @identifiers
        end

        def exit_with_error(msg, status)
          STDERR.puts msg
          exit status
        end

        def options(option_parser, options); end
      end

      def initialize(*args, **options)
        @args = args.dup
        @options = options
        parse_options!
      end

      private

      def parse_options!
        parser = OptionParser.new
        common_options(parser, options)
        self.class.options(parser, options)
        parser.parse!(args)
      rescue OptionParser::InvalidOption => e
        raise ArgumentError, e.message
      end

      def common_options(parser, _options)
        parser.on('--trace', 'Show backtrace on command failure')
      end
    end
  end
end
