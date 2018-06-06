require 'rubygems/package'
require 'zlib'
require 'set'
require 'digest'
require 'open3'

module Shaf
  module Upgrade
    class Package
      include Comparable

      class UpgradeError < StandardError; end
      class VersionNotFoundError < UpgradeError; end
      class VersionConflictError < UpgradeError; end
      class ManifestNotFoundError < UpgradeError; end
      class MissingPatchError < UpgradeError; end
      class PatchNotInManifestError < UpgradeError; end
      class BadChecksumError < UpgradeError; end

      UPGRADE_FILES_PATH = File.join(Utils.gem_root, 'upgrades').freeze
      MANIFEST_FILENAME = 'manifest'.freeze

      attr_reader :version

      class << self
        def all
          target_versions.map(&method(:new))
        end

        def load(version)
          v = strip_suffix(version)
          raise VersionNotFoundError unless target_versions.include? v
          new(v).tap(&:load)
        end

        private

        def target_versions
          return @target_versions if @target_versions

          files = Dir[File.join(UPGRADE_FILES_PATH, '*.tar.gz')]
          @target_versions = files.each_with_object([]) do |file, versions|
            str = File.basename(file, '.tar.gz')
            versions << Version.new(str)
          end
        end

        def strip_suffix(file)
          file.sub('.tar.gz', '')
        end
      end

      def initialize(version)
        @version = Version.new(version)
        @manifest = nil
        @patches = {}
      end

      def load
        File.open(tarball, 'rb') do |file|
          Zlib::GzipReader.wrap(file) do |gz|
            Gem::Package::TarReader.new(gz) do |tar|
              tar.each(&method(:add_tar_entry))
            end
          end
        end
        validate
        self
      end

      def <=>(other)
        version = other.is_a?(String) ? other : other.version
        @version <=> version
      end

      def apply(dir = nil)
        files_in(dir).each do |file|
          chksum = @manifest.chksum_for(file)
          next unless chksum
          patch = @patches[chksum]
          apply_patch(file, patch)
        end
      end

      def to_s
        if @manifest.nil?
          "Shaf::Upgrade::Package for version #{@version}"
        else
          count = @patches.size
          count_str = "#{count} patch#{count == 1 ? "" : "es"}" 
          "Shaf::Upgrade::Package for version #{@version}, containing #{count_str}"
        end
      end

      private

      def tarball
        file = File.join(UPGRADE_FILES_PATH, "#{@version}.tar.gz")
        return file if File.exist? file
        raise VersionNotFoundError
      end

      def add_tar_entry(entry)
        filename = entry.full_name
        content = entry.read

        if filename == MANIFEST_FILENAME
          parse_manifest content
        else
          @patches[filename] = content
        end
      end

      def parse_manifest(content)
        h = YAML.safe_load(content)
        @manifest = Manifest.new(
          target_version: h['target_version'],
          patches: h['patches']
        )
      end

      def validate
        raise ManifestNotFoundError unless @manifest
        raise VersionConflictError unless @version == @manifest.target_version

        from_manifest = @manifest.patches.keys.to_set
        from_file = @patches.keys.to_set
        raise MissingPatchError if from_file < from_manifest
        raise PatchNotInManifestError if from_manifest < from_file

        @patches.each do |md5, content|
          raise BadChecksumError unless Digest::MD5.hexdigest(content) == md5
        end

        true
      end

      def files_in(dir)
        dir += '/' if !dir.nil? && dir[-1] != '/'
        Dir["#{dir}**/*"]
      end

      def apply_patch(file, patch)
        success = nil
        Open3.popen3('patch', file, '-r', '-') do |i, o, e, t|
          i.write patch
          i.close
          puts o.read
          err = e.read
          puts err unless err.empty?
          success = t.value.success?
        end
        success
      end

    end
  end
end
