# frozen_string_literal: true

require 'shaf/yard/base_method_handler'
require 'shaf/profiles'
require 'shaf/utils'

module Shaf
  module Yard
    # Handles call to Shaf::Serializer::profile
    class ProfileMethodHandler < BaseMethodHandler
      include Shaf::Utils

      handles method_call(:profile)

      def process
        serializer = serializer_namespace
        profile = shaf_profile
        return unless serializer

        serializer.profile = profile

        register object
        serializer_namespace.profile_objects << object
      end

      def shaf_profile
        return @shaf_profile if defined? @shaf_profile

        bootstrap(env: ENV['RACK_ENV'])

        @shaf_profile = Shaf::Profiles.find name
      end

      def object
        # Put the Profile object on the the same namespace level as
        # the serializer. Typically this it the root namespace
        ns = namespace.namespace

        name = shaf_profile&.to_s || self.name
        name.gsub!(/(Shaf|Profiles)?::/, "")

        name << "Profile" unless name.end_with? "Profile"

        ProfileObject.new(ns, name).tap do |obj|
          obj.dynamic = true
          obj.profile = shaf_profile
        end
      end
    end
  end
end
