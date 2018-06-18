require 'yaml'

module Shaf
  module Upgrade
    class Manifest
      attr_reader :target_version, :patches

      def initialize(target_version:, patches: {})
        @target_version = target_version
        @patches = build_patterns(patches)
      end

      def build_patterns(patches)
        patches.each_with_object({}) do |(chksum, pattern), hash|
          hash[chksum] = /#{pattern}/
        end
      end

      def patch_name_for(file)
        @patches.select { |_, pattern| pattern =~ file }.keys.first
      end
    end
  end
end

# Example of manifest:
# ---
# target_version: 0.4.0
# patches:
#   cd5b0bf61070a9fd57e60c45e9aaf64a: config/database.rb
#   59783ecfa5f41b84c6fad734e7aa6a1d: Rakefile
