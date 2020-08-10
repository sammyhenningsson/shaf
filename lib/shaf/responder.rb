require 'set'

module Shaf
  module Responder
    class << self
      def register(responder)
        uninitialized << responder
      end

      def unregister(responder)
        responders.delete_if { |_, r| r == responder }
        supported_responders.each do |_klass, responders|
          responders.delete_if { |r| r == responder }
        end
      end

      def for(request, resource)
        types = supported_responders_for(resource).map(&:mime_type)
        types = move_html_to_last(types)
        mime = request.preferred_type(types)
        responders[mime]
      end

      def default=(responder)
        responders.default = responder
      end

      def default
        responders.default
      end

      private

      def supported_responders_for(resource)
        klass = resource.is_a?(Class) ? resource: resource.class
        if supported_responders[klass].empty?
          responders.each do |_mime, responder|
            next unless responder.can_handle? resource
            supported_responders[klass] << responder
          end
        end
        supported_responders[klass].to_a
      end

      def supported_responders
        @supported_responders ||= Hash.new { |hash, key| hash[key] = Set.new }
      end

      def uninitialized
        @uninitialized ||= []
      end

      def init_responders!
        while responder = uninitialized.shift
          mime = responder.mime_type
          @responders[mime] = responder
        end
      end

      def responders
        (@responders ||= {}).tap do
          init_responders!
        end
      end

      # We want to always be able to respond with text/html, but only when
      # asked for (Accept header) to be able to let other more specific mime
      # types take precedence we need to move text/html to the end of the
      # array.
      def move_html_to_last(types)
        return types unless types.include? Html.mime_type

        (types - [Html.mime_type]) << Html.mime_type
      end
    end
  end
end

require 'shaf/responder/base'
require 'shaf/responder/hal'
require 'shaf/responder/html'
require 'shaf/responder/problem_json'
require 'shaf/responder/alps_json'
