# frozen_string_literal: true

require 'set'

module Shaf
  module Parser
    class Error < StandardError; end

    INPUT_BODY = 'shaf.input_body'

    class << self
      def register(parser)
        parsers << parser
      end

      def unregister(parser)
        parsers.delete(parser)
      end

      def input?(request)
        !!input(request)
      end

      def for(request)
        clazz = parser_for(request)
        return unless clazz

        body = input(request)
        clazz.new(request: request, body: body)
      end

      private

      def parser_for(request)
        parsers.find do |parser|
          parser.can_handle? request
        end
      end

      def parsers
        @parsers ||= Set.new
      end

      def input(request)
        body = request.get_header(INPUT_BODY)
        body ||= read_input(request).tap do |b|
          request.set_header(INPUT_BODY, b)
        end

        body unless String(body).strip.empty?
      end

      def read_input(request)
        request.body.rewind
        request.body.read
      ensure
        request.body.rewind
      end
    end
  end
end

require 'shaf/parser/base'
require 'shaf/parser/json'
require 'shaf/parser/form_data'
