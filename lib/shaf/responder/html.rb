module Shaf
  module Responder
    class Html < Base
      mime_type :html

      def body
        case resource
        when Formable::Form
          controller.erb(:form, locals: {form: resource, serialized: serialize})
        else
          controller.erb(:payload, locals: {serialized: serialize})
        end
      end
    end
  end
end
