module Shaf
  module Responder
    class Response
      attr_reader :content_type, :body, :serialized_hash, :resource

      def initialize(content_type:, body:, serialized_hash: {}, resource: nil)
        @content_type = content_type
        @body = body
        @serialized_hash = serialized_hash
        @resource = resource
      end

      def log_entry
        "Response (#{resource.class}) payload: #{body}"
      end
    end

    class Base
      PRELOAD_FAILED_MSG = "Failed to preload '%s'. Link could not be extracted from response"

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
          response = responder.build_response
          log_response(controller, response)
          preload_links = preload_links(preload, responder, response, controller)
          write_response(controller, response, preload_links)
        end

        def can_handle?(_obj)
          true
        end

        private

        def log_response(controller, response)
          log(controller, response.log_entry)
        end

        def log(controller, msg, type: :debug)
          return unless controller.respond_to? :log
          controller.log.send(type, msg)
        end

        def preload_links(rels, responder, response, controller = nil)
          Array(rels).map do |rel|
            links = responder.lookup_rel(rel, response)
            links = [links].compact unless links.is_a? Array
            log(controller, PRELOAD_FAILED_MSG % rel) if links.empty?
            links
          end
        end

        def write_response(controller, response, preload_links)
          controller.content_type(response.content_type)
          add_preload_links(controller, response, preload_links)
          controller.body(response.body)
        end

        def add_preload_links(controller, response, preload_links)
          preload_links.each do |links|
            links.each do |link|
              next unless link[:href]
              # Nginx http2_push_preload only processes relative URIs with absolute path
              href = link[:href].sub(%r{https?://[^/]+}, "")
              type = link.fetch(:as, 'fetch')
              xorigin = link.fetch(:crossorigin, 'anonymous')
              links = (controller.headers['Link'] || "").split(',').map(&:strip)
              links << "<#{href}>; rel=preload; as=#{type}; crossorigin=#{xorigin}"
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

      def serialized_hash
        {}
      end

      def build_response
        Response.new(
          content_type: mime_type,
          body: body,
          serialized_hash: serialized_hash,
          resource: resource
        )
      end

      def lookup_rel(_rel, _response)
        []
      end

      private

      def mime_type
        self.class.mime_type
      end

      def user
        options.fetch(:current_user) do
          controller.current_user if controller.respond_to? :current_user
        end
      end
    end
  end
end

