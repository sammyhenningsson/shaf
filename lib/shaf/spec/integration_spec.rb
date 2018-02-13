module Shaf
  module Spec
    class IntegrationSpec < Minitest::Spec
      include Minitest::Hooks
      include HttpMethodUtils
      include PayloadUtils
      include UriHelper

      TRANSACTION_OPTIONS = {
        rollback: :always,
        savepoint: true,
        auto_savepoint: true
      }.freeze

      register_spec_type self do |desc, args|
        next unless args && args.is_a?(Hash)
        args[:type]&.to_s == 'integration'
      end

      around do |&block|
        DB.transaction(TRANSACTION_OPTIONS) { super(&block) }
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
