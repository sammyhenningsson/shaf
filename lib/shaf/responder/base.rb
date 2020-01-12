module Shaf
  module Responder
    class Response
      attr_reader :content_type, :body, :resource, :serialized

      def initialize(content_type, body, resource, serialized = nil)
        @content_type = content_type
        @body = body
        @resource = resource
        @serialized = serialized
      end
    end

    class Base
      class << self
        def mime_type(type = nil, value = nil)
          if type
            @mime_type = type
            @mime_type = Sinatra::Base.mime_type(type, value) if type.is_a? Symbol
            Responder.register(self)
          elsif defined? @mime_type
            @mime_type
          else
            raise Error, "Class #{self} must register a mime type"
          end
        end

        def use_as_default!
          Responder.default = self
        end

        def call(controller, resource, preload: [], **kwargs)
          responder = new(controller, resource, **kwargs)
          response = responder.response
          log_response(controller, response)
          write_response(controller, response, preload: preload)
        end

        def can_handle?(_obj)
          true
        end

        def lookup_rel(rel, response)
          []
        end

        private

        def log_response(controller, response)
          log(
            controller,
            "Response (#{response.resource.class}) payload: #{response.serialized}"
          )
        end

        def log(controller, msg, type: :debug)
          return unless controller.respond_to? :log
          controller.log.send(type, msg)
        end

        def write_response(controller, response, preload:)
          controller.content_type(response.content_type)
          add_preload_links(controller, response, preload)
          controller.body(response.body)
        end

        def add_preload_links(controller, response, preload)
          Array(preload).each do |rel|
            links = Array(lookup_rel(rel, response))
            next log(
              controller,
              "Failed to preload '#{rel}', link could not be extracted from response"
            ) if links.empty?

            links.each do |href, type|
              next unless href
              # Nginx http2_push_preload only processes relative URIs with absolute path
              href.sub!(%r{https?://\w+(:\d+)?}, "")
              type ||= 'object'
              links = (controller.headers['Link'] || "").split(',').map(&:strip)
              links << "<#{href}>; rel=preload; as=#{type}"
              controller.headers["Link"] = links.join(', ') unless links.empty?
            end
          end
        end
      end

      attr_reader :controller, :resource, :options

      def initialize(controller, resource, **options)
        @controller = controller
        @resource = resource
        @options = options
      end

      def body
        raise NotImplementedError, "#{self.class} must implement #body"
      end

      def serialized
        @serialize
      end

      def response
        Response.new(mime_type, body, resource, serialized)
      end

      private

      def mime_type
        self.class.mime_type
      end

      def collection?
        !!options.fetch(:collection, false)
      end

      def user
        options.fetch(:current_user) do
          controller.current_user if controller.respond_to? :current_user
        end
      end

      def serializer
         @serializer ||= options[:serializer] || HALPresenter.lookup_presenter(resource)
      end

      def serialize
        return "" unless serializer

        @serialize ||=
          if collection?
            serializer.to_collection(resource, current_user: user, **options)
          else
            serializer.to_hal(resource, current_user: user, **options)
          end
      end
    end
  end
end

