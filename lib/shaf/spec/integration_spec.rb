# frozen_string_literal: true

module Shaf
  module Spec
    class IntegrationSpec < Base
      include PayloadUtils
      include HttpUtils

      register_spec_type self do |desc, args|
        next unless args&.is_a?(Hash)
        args[:type]&.to_s == 'integration'
      end

      def set_headers
        if defined?(@__integration_test_auth_token) && @__integration_test_auth_token
          header 'X-AUTH-TOKEN', @__integration_test_auth_token
        end
      end

      def parse_response(body)
        return nil if body.empty?
        JSON.parse(body, symbolize_names: true)
      rescue JSON::ParserError => e
        assert e.nil?, "Could not parse reponse as json (#{body[0..40]})"
      end

      def app
        App.instance
      end

      def follow_rel(rel, method: nil)
        assert_has_link(rel)
        link = links[rel.to_sym]
        if method && respond_to?(method)
          public_send(method, link[:href])
        else
          get link[:href]
        end
      end

      def auth_token(token)
        @__integration_test_auth_token = token
      end

      def clear_auth_token
        @__integration_test_auth_token = nil
      end
    end
  end
end
