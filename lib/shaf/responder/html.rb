module Shaf
  module Responder
    class Html < Base
      mime_type :html

      class << self
        def call(controller, resource, preload: [], **kwargs)
          responder = responder_for(resource, controller, preload_rels: preload, **kwargs)
          response = responder.build_response
          add_preload_links(controller, response)

          html_responder = new(controller, resource, response: response)
          html_response = html_responder.build_response
          log_response(controller, response)

          write_response(controller, html_response)
        end


        # Returns the "original" (non-html) responder
        def responder_for(resource, controller, **kwargs)
          responders = Responder.send(:supported_responders_for, resource)
          responder_class = (responders - [self]).first || Responder.default
          responder_class.new(controller, resource, **kwargs)
        end
      end

      def body
        response = options[:response]
        serialized = response.serialized_hash
        if serialized.empty?
          serialized = begin
                         JSON.parse(response.body)
                       rescue StandardError
                         response.body
                       end
        end

        render serialized
      end

      def render(serialized)
        locals = {
          request_headers: request_headers,
          response_headers: response_headers,
          serialized: serialized
        }

        template =
          case resource
          when Formable::Form
            locals.merge!(form: resource)
            :form
          else
            :payload
          end

        controller.erb(template, locals: locals)
      end

      def request_headers
        controller.request_headers
      end

      def response_headers
        etag, kind = controller.send(:etag_for, options[:response].body)
        prefix = kind == :weak ? 'W/' : ''
        etag = %Q{#{prefix}"#{etag}"}

        type = options[:response].content_type

        controller.headers.merge('Content-Type' => type, 'ETag' => etag)
      end
    end
  end
end
