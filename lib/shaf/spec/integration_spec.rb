module Shaf
  module Spec
    class IntegrationSpec < Minitest::Spec
      include Minitest::Hooks
      include ::Rack::Test::Methods
      include PayloadUtils

      register_spec_type self do |desc, args|
        return unless args && args.is_a?(Hash)
        args[:type]&.to_s == 'integration'
      end

      [:get, :put, :post, :delete].each do |m|
        define_method m do |*args|
          set_headers
          super(*args)
          @payload = parse_response(last_response.body)
        end
      end

      def set_headers
        if @__integration_test_auth_token
          header 'X-AUTH-TOKEN', @__integration_test_auth_token
        end
      end

      def parse_response(body)
        return nil if body.empty?
        JSON.parse(body, symbolize_names: true)
      end

      def app
        App.instance
      end

      def headers
        last_response&.headers
      end

      def status
        last_response&.status
      end

#       def login(email, pass)
#         params = {email: email, password: pass}
#         header 'Content-Type', 'application/json'
#         post Shaf::UriHelper.session_uri, JSON.generate(params)
#         @__integration_test_auth_token = attribute[:auth_token]
#       end
# 
#       def logout
#         delete Shaf::UriHelper.session_uri
#         @__integration_test_auth_token = nil
#       end

    end
  end
end
