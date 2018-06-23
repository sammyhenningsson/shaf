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
        Shaf::Upgrade::Package.all.select { |package| package > current_version }
      end

      def current_version
        read_shaf_version or raise UnknownShafVersionError
      end
    end
  end
end
