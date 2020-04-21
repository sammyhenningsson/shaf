require 'shaf/responder/hal_serializable'

module Shaf
  module Responder
    class Html < Base
      include HalSerializable

      mime_type :html

      def body
        locals = variables

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

      def variables
        {
          request_headers: request_headers,
          response_headers: response_headers,
          serialized: serialized_hash
        }
      end

      def request_headers
        controller.request_headers
      end

      def response_headers
        etag, kind = controller.send(:etag_for, generate_json)
        prefix = kind == :weak ? 'W/' : ''
        etag = %Q{#{prefix}"#{etag}"}

        type = Hal.mime_type
        type = "#{type};profile=#{profile}" if profile

        controller.headers.merge('Content-Type' => type, 'ETag' => etag)
      end
    end
  end
end
