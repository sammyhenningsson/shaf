require 'rubygems/package'
require 'zlib'
require 'set'
require 'digest'
require 'open3'
require 'fileutils'

module Shaf
  module Upgrade
    class Package
      include Comparable

      class UpgradeError < StandardError; end
      class VersionNotFoundError < UpgradeError; end
      class VersionConflictError < UpgradeError; end
      class ManifestNotFoundError < UpgradeError; end
      class MissingFileError < UpgradeError; end
      class FileNotInManifestError < UpgradeError; end
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
          return @target_versions if defined? @target_versions

          files = Dir[File.join(UPGRADE_FILES_PATH, '*.tar.gz')]
          @target_versions = files.map do |file|
            str = File.basename(file, '.tar.gz')
            Version.new(str)
          end.sort
        end

        def strip_suffix(file)
          file.sub('.tar.gz', '')
        end
      end

      def initialize(version)
        @version = Version.new(version)
        @manifest = nil
        @files = {}
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
        apply_patches
        apply_additions
      end

      def to_s
        str = "Shaf::Upgrade::Package for version #{@version}"
        return str if @manifest.nil?
        "#{str}, containing #{@manifest.stats}"
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
          @files[filename] = content
        end
      end

      def parse_manifest(content)
        h = YAML.safe_load(content)
        @manifest = Manifest.new(h)
      end

      def validate
        raise ManifestNotFoundError unless @manifest
        raise VersionConflictError unless @version == @manifest.target_version

        from_file = @files.keys.to_set

        manifest_patches = @manifest.patches.keys.to_set
        raise MissingFileError if from_file < manifest_patches


        manifest_added = @manifest.added.keys.to_set
        raise MissingFileError if from_file < manifest_added

        manifest_removed = @manifest.added.keys.to_set
        raise MissingFileError if from_file < manifest_removed

        raise FileNotInManifestError if @manifest.files.keys.to_set < from_file

        @files.each do |md5, content|
          raise BadChecksumError unless Digest::MD5.hexdigest(content) == md5
        end

        true
      end

      def apply_patches
        files_in(dir).all? do |file|
          name = @manifest.patch_for(file) # returns nil when file
          next true unless name                 # shouldn't be patched
          patch = @files[name]
          apply_patch(file, patch)
        end
      end

      def apply_additions
        @manifest.each_addition do |chksum, filename|
          content = @files[chksum]
          FileUtils.mkdir_p File.dirname(filename)
          File.open(filename, 'w') { |file| file.write(content) }
        end
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
