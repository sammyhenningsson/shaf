module Shaf
  module Parser
    class FormData < Base
      def self.can_handle?(request)
        request.form_data? || request.parseable_data?
      end

      def call
        request.POST.tap do |data| # Returns form params from Rack::Request
          data.delete '_method' # If the method override hack is used remove the _method key
        end
      end
    end
  end
end
