require 'yaml'

module Shaf
  module Upgrade
    class Manifest
      attr_reader :target_version

      def initialize(**params)
        @target_version = params[:target_version]
        @files = {}
        @files[:patch] = build_patterns(params[:patches])
        @files[:add] = params[:add] || {}
        @files[:drop] = (params[:drop] || []).map { |d| Regexp.new(d) }
        @files[:regexp] = build_patterns(params[:substitutes])
      end

      def patches
        files[:patch]
      end

      def additions
        files[:add]
      end

      def removals
        files[:drop]
      end

      def regexps
        files[:regexp]
      end

      def patches_for(file)
        patches.select { |_, pattern| file =~ pattern }.keys
      end

      def regexps_for(file)
        regexps.select { |_, pattern| file =~ pattern }.keys
      end

      def drop?(file)
        removals.any? { |pattern| file =~ pattern }
      end

      def stats
        {
          additions: additions.size,
          removals: removals.size,
          patches: patches.size,
          regexps: regexps.size
        }
      end

      def stats_str
        "Add: #{additions.size}, " \
          "Del: #{removals.size}, " \
          "Patch: #{patches.size}, " \
          "Regexp: #{regexps.size}"
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
# substitutes:
#   d3b07384d113edec49eaa6238ad5ff00: api/models/.*.rb
