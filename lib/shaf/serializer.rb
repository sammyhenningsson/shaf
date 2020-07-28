# frozen_string_literal: true

module Shaf
  # A base class used for serializing objects into a HAL representations.
  class Serializer
    extend HALPresenter
    extend UriHelper

    class << self
      attr_reader :default_curie_prefix

      # Creates a link with rel profile and href pointing to the corresponding profile.
      # It also adds a Curie link.
      # @param name [String] the name of the profile
      # @param curie_prefix [Symbol] the prefix used for the Curie
      def profile(name, curie_prefix: :doc)
        link :profile do
          profile_uri(name)
        end

        curie curie_prefix do
          doc_curie_uri(name)
        end

        @default_curie_prefix = curie_prefix.to_sym
      end
    end
  end
end
