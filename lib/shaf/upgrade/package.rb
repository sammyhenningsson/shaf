require 'rubygems/package'
require 'zlib'
require 'set'
require 'digest'
require 'open3'
require 'fileutils'
require 'tempfile'
require 'yaml'

module Shaf
  module Upgrade
    class Package
      include Comparable

      class UpgradeError < StandardError; end
      class VersionNotFoundError < UpgradeError; end
      class VersionConflictError < UpgradeError; end
      class ManifestNotFoundError < UpgradeError; end
      class MissingFileError < UpgradeError; end
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

      def initialize(version, manifest = nil, files = {})
        @version = Version.new(version)
        @manifest = manifest
        @files = files
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
        apply_patches(dir)
        apply_additions
        apply_drops(dir)
        apply_substitutes(dir)
      end

      def to_s
        str = "Shaf::Upgrade::Package for version #{@version}"
        return str if @manifest.nil?
        "#{str} (#{@manifest.stats})"
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
        hash = YAML.safe_load(content)
        @manifest = Manifest.new(
          target_version: hash["target_version"],
          patches: hash["patches"],
          add: hash["add"],
          drop: hash["drop"],
          substitutes: hash["substitutes"]
        )
      end

      def validate
        raise ManifestNotFoundError unless @manifest
        raise VersionConflictError unless @version == @manifest.target_version

        from_file = @files.keys.to_set

        manifest_patches = @manifest.files[:patch].keys.to_set
        raise MissingFileError if from_file < manifest_patches

        to_add = @manifest.files[:add].keys.to_set
        raise MissingFileError if from_file < to_add

        @files.each do |md5, content|
          raise BadChecksumError unless Digest::MD5.hexdigest(content) == md5
        end

        true
      end

      def files_in(dir)
        dir += '/' if !dir.nil? && dir[-1] != '/'
        Dir["#{dir}**/*"]
      end

      def apply_patches(dir = nil)
        files_in(dir).all? do |file|
          @manifest.patch_for(file).all? do |name|
            patch = @files[name]
            apply_patch(file, patch)
          end
        end
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

      def apply_additions
        @manifest.files[:add].each do |chksum, filename|
          content = @files[chksum]
          FileUtils.mkdir_p File.dirname(filename)
          File.open(filename, 'w') { |file| file.write(content) }
        end
      end

      def apply_drops(dir = nil)
        files_in(dir).map do |file|
          File.unlink(file) if @manifest.drop?(file)
        end
      end

      def apply_substitutes(dir = nil)
        files_in(dir).all? do |file|
          @manifest.regexp_for(file).all? do |name|
            params = symbolize_keys(YAML.safe_load(@files[name]))
            apply_substitute(file, params)
          end
        end
      end

      def apply_substitute(file, params)
        return unless params[:pattern] && params[:replace]

        pattern = Regexp.new(params[:pattern])
        replacement = params[:replace]

        tmp = Tempfile.open do |new_file|
          File.readlines(file).each do |line|
            new_file << line.gsub(pattern, replacement)
          end
          new_file
        end

        FileUtils.mv(tmp.path, file)
      end

      # Refactor this when support for ruby < 2.5 is dropped
      def symbolize_keys(hash)
        hash.each_with_object({}) { |(k, v), h| h[k.to_sym] = v }
      end
    end
  end
end
