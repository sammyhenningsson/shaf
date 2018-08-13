require 'yaml'

module Shaf
  module Upgrade
    class Manifest
      attr_reader :target_version, :files

      def initialize(target_version:, patches: nil, add: nil, drop: nil)
        @target_version = target_version
        @files = {}
        @files[:patch] = build_patterns(patches)
        @files[:add] = add || {}
        @files[:drop] = (drop || []).map { |d| Regexp.new(d) }
      end

      def patch_for(file)
        first_match = files[:patch].find { |_, pattern| file =~ pattern }
        (first_match || []).first
      end

      def drop?(file)
        files[:drop].any? { |pattern| file =~ pattern }
      end

      def stats
        "Add: #{files[:add].size}, " \
          "Del: #{files[:drop].size}, " \
          "Patch: #{files[:patch].size}"
      end

      private

      def build_patterns(patches)
        return {} unless patches
        patches.each_with_object({}) do |(chksum, pattern), hash|
          hash[chksum] = Regexp.new(pattern)
        end
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
# add:
#   8ece24b8c440675bd3d188155909431c: api/policies/base_policy.rb
# drop:
# - api/policies/base_policy.rb
