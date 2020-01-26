require 'shaf/responder/hal_serializable'

module Shaf
  module Responder
    class Html < Base
      include HalSerializable

      mime_type :html

      def body
        case resource
        when Formable::Form
          controller.erb(:form, locals: {form: resource, serialized: serialized_hash})
        else
          controller.erb(:payload, locals: {serialized: serialized_hash})
        end
      end
    end
  end
end
