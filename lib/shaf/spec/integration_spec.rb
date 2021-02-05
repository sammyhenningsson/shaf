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

      def parse_response(body)
        return nil if body.empty?
        JSON.parse(body, symbolize_names: true)
      rescue JSON::ParserError => e
        assert e.nil?, "Could not parse reponse as json (#{body[0..40]})"
      end

      def app
        App.app
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
