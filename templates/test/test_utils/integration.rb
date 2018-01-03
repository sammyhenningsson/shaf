require 'test/test_utils/payload'

module TestUtils
  module Integration

    module HTTPMethodsOverrides
      [:get, :put, :post, :delete].each do |m|
        define_method m do |*args|
          set_headers
          super(*args)
          @payload = parse_response(last_response.body)
        end
      end

      def set_headers
        if @_integration_test_auth_token
          header 'X-AUTH-TOKEN', @_integration_test_auth_token
        end
      end

      def parse_response(body)
        return nil if body.empty?
        JSON.parse(body, symbolize_names: true)
      end
    end

    module Test
      include ::Rack::Test::Methods
      include ::TestUtils::Payload
      prepend HTTPMethodsOverrides

      def app
        App.instance
      end

      def headers
        last_response&.headers
      end

      def status
        last_response&.status
      end

      def login(email, pass)
        params = {email: email, password: pass}
        header 'Content-Type', 'application/json'
        post UriHelper.session_uri, JSON.generate(params)
        @_integration_test_auth_token = attribute[:auth_token]
      end

      def logout
        delete UriHelper.session_uri
        @_integration_test_auth_token = nil
      end
    end

  end
end
