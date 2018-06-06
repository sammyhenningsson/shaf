require 'test_helper'

module Shaf

  describe Command::Upgrade do
    let(:cmd) { Command::Upgrade.new }

    it "#upgrade_packages" do
      packages = [
        Shaf::Upgrade::Package.new('1.0.0'),
        Shaf::Upgrade::Package.new('2.0.0'),
        Shaf::Upgrade::Package.new('3.0.0')
      ]

      Shaf::Upgrade::Package.stub :all, packages do
        cmd.stub :read_shaf_version, '1.2.0' do
          selected_versions= cmd.upgrade_packages.map { |u| u.version.to_s }
          assert_equal ['2.0.0', '3.0.0'], selected_versions
        end

        cmd.stub :read_shaf_version, '2.0.0' do
          selected_versions= cmd.upgrade_packages.map { |u| u.version.to_s }
          assert_equal ['3.0.0'], selected_versions
        end

        cmd.stub :read_shaf_version, '3.0.0' do
          selected_versions= cmd.upgrade_packages.map { |u| u.version.to_s }
          assert_equal [], selected_versions
        end
      end
    end
  end
end
