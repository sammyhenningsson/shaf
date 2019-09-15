require 'shaf/upgrade'

module Shaf
  module Command
    class Upgrade < Base

      class UnknownShafVersionError < CommandError; end
      class UpgradeFailedError < CommandError
        attr_reader :version

        def initialize(version)
          @version = version
        end
      end

      identifier %r(\Aupgrade\Z)
      usage 'upgrade'

      def self.options(parser, options)
        parser.on('--skip VERSION', String, 'Skip version') do |v|
          options[:skip_version] = Shaf::Upgrade::Version.new(v)
        end
      end

      def call
        in_project_root do
          upgrade_packages.each { |package| apply(package) }
          puts "\nProject is up-to-date! Shaf version: #{current_version}"
        end
      rescue UpgradeFailedError => e
        puts <<~ERR
        
          Failed to upgrade project to version #{e.version}
          Please try resolve these issues manually and try again.
          For more info see:
          https://github.com/sammyhenningsson/shaf/blob/master/doc/UPGRADE.md
        ERR
      end

      def apply(package)
        unless skip? package
          package.load.apply or raise UpgradeFailedError.new(package.version)
        end
        write_shaf_version package.version.to_s
      rescue Errno::ENOENT
        raise UpgradeFailedError,
          "Failed to execute system command 'patch'. Make sure that 'patch' installed!" \
          " (E.g. `sudo apt install patch` for Ubuntu)"
      end

      def skip?(package)
        return false unless options[:skip_version]
        package.version == options[:skip_version]
      end

      def upgrade_packages
        current = current_version
        target = target_version

        Shaf::Upgrade::Package.all.select do |package|
          current < package.version && package.version <= target
        end
      end

      def current_version
        version = read_shaf_version or raise UnknownShafVersionError
        Shaf::Upgrade::Version.new(version)
      end

      def target_version
        Shaf::Upgrade::Version.new(ENV.fetch('UPGRADE_TARGET', '99.9.9'))
      end
    end
  end
end
