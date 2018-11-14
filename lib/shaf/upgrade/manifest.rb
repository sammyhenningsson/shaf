require 'yaml'

module Shaf
  module Upgrade
    class Manifest
      attr_reader :target_version, :files

      def initialize(**params)
        @target_version = params[:target_version]
        @files = {}
        @files[:patch] = build_patterns(params[:patches])
        @files[:add] = params[:add] || {}
        @files[:drop] = (params[:drop] || []).map { |d| Regexp.new(d) }
        @files[:regexp] = build_patterns(params[:substitutes])
      end

      def patch_for(file)
        files[:patch].select { |_, pattern| file =~ pattern }.keys
      end

      def regexp_for(file)
        files[:regexp].select { |_, pattern| file =~ pattern }.keys
      end

      def drop?(file)
        files[:drop].any? { |pattern| file =~ pattern }
      end

      def stats
        "Add: #{files[:add].size}, " \
          "Del: #{files[:drop].size}, " \
          "Patch: #{files[:patch].size}, " \
          "Regexp: #{files[:regexp].size}"
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
