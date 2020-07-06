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
        return unless serializer && profile

        serializer.profile = profile
      end

      def shaf_profile
        bootstrap(env: ENV['RACK_ENV'])

        Shaf::Profiles.find name
      end
    end
  end
end
