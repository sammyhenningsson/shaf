module Shaf
  module Parser
    class Base
      class << self
        def inherited(child)
          Parser.register(child)
          super
        end

        def mime_type(type = nil, value = nil)
          if type
            @mime_type = type
            @mime_type = Sinatra::Base.mime_type(type, value) if type.is_a? Symbol
          end

          @mime_type if defined? @mime_type
        end

        def can_handle?(request)
          mime_type == request.content_type
        end

      end

      attr_reader :request, :body

      def initialize(request:, body:)
        @request = request
        @body = body
      end

      def call
        raise NotImplementedError, "#{self.class} must implement #call"
      end

      private

      def mime_type
        self.class.mime_type
      end
    end
  end
end

