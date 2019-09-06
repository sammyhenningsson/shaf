require 'shaf/upgrade'

module Shaf
  module Command
    class Upgrade < Base

      class UnknownShafVersionError < CommandError; end
      class UpgradeFailedError < CommandError; end

      identifier %r(\Aupgrade\Z)
      usage 'upgrade'

      def call
        in_project_root do
          upgrade_packages.each { |package| apply(package) }
          puts "\nProject is up-to-date! Shaf version: #{current_version}"
        end
      end

      def apply(package)
        package.load.apply or raise UpgradeFailedError
        write_shaf_version package.version.to_s
      rescue Errno::ENOENT
        raise UpgradeFailedError,
          "Failed to execute system command 'patch'. Make sure that 'patch' installed!" \
          " (E.g. `sudo apt install patch` for Ubuntu)"
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
