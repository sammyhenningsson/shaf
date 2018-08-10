require 'yaml'

module Shaf
  module Upgrade
    class Manifest
      attr_reader :target_version, :patches, :added, :removed

      def initialize(target_version:, patches: {}, added: {}, removed: {})
        @target_version = target_version
        @patches = build_patterns(patches)
        @added = added
        @removed = removed
      end

      def build_patterns(patches)
        patches.each_with_object({}) do |(chksum, pattern), hash|
          hash[chksum] = /#{pattern}/
        end
      end

      def patch_for(file)
        patches.select { |_, pattern| pattern =~ file }.keys.first
      end

      def each_addition
        added.each { |chksum, filename| yield [chksum, filename] }
      end

      def files
        patches.merge(added).merge(removed)
      end

      def stats
        "Add: #{added.size}, Del: #{removed.size}, Patch: #{patches.size}"
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
# added:
#   8ece24b8c440675bd3d188155909431c: base_policy.rb
