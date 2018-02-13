module Shaf
  module Spec
    module HttpMethodUtils
      include ::Rack::Test::Methods

      [:get, :put, :post, :delete].each do |m|
        define_method m do |*args|
          set_headers
          super(*args)
          set_payload parse_response(last_response.body)
        end
      end

      def status
        last_response&.status
      end

      def headers
        last_response&.headers
      end

    end
  end
end
