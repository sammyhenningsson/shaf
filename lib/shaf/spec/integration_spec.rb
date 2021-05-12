# frozen_string_literal: true

module Shaf
  module Spec
    class IntegrationSpec < Base
      include PayloadUtils
      include HttpUtils

      register_spec_type self do |_desc, args|
        next unless args&.is_a?(Hash)
        args[:type].to_s == 'integration'
      end

      private

      attr_accessor :__authenticated_user_id

      def set_authentication
        id = __authenticated_user_id
        authorization = "#{Authenticator.scheme} #{id}" if id

        header 'Authorization', authorization
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

      def authenticate(user)
        self.__authenticated_user_id = user&.id
      end

      def unauthenticate
        self.__authenticated_user_id = nil
      end

      def with_authenticated(user, &block)
        authenticate(user)
        yield
      ensure
        unauthenticate
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
    end
  end
end
