require 'shaf/responder/hal_serializable'

module Shaf
  module Responder
    class Html < Base
      include HalSerializable

      mime_type :html

      def body
        locals = {
          request_headers: controller.request_headers,
          response_headers: controller.headers,
          serialized: serialized_hash
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
    end
  end
end
