# frozen_string_literal: true

module Shaf
  module Command
    class Server < Base

      identifier %r(\As(erver)?\Z)
      usage 'server'

      def self.options(parser, options)
        parser.on('-p', '--port PORT', Integer, 'Listen port') do |p|
          options[:port] = p
        end
      end

      def call
        Settings.port = options[:port] if options[:port]
        bootstrap
        App.run!
      end
    end
  end
end

