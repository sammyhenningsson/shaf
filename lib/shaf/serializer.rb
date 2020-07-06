# frozen_string_literal: true

module Shaf
  # A base class used for serializing objects into a HAL representations.
  class Serializer
    extend HALPresenter
    extend UriHelper

    class << self
      # Creates a link with rel profile and href pointing to the corresponding profile.
      # @param name [String] the name of the profile
      def profile(name, curie: :doc)
        link :profile do
          profile_path(name)
        end
      end
    end
  end
end
