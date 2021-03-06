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
          selected_versions = cmd.upgrade_packages.map { |u| u.version.to_s }
          assert_equal ['2.0.0', '3.0.0'], selected_versions
        end

        cmd.stub :read_shaf_version, '2.0.0' do
          selected_versions = cmd.upgrade_packages.map { |u| u.version.to_s }
          assert_equal ['3.0.0'], selected_versions
        end

        cmd.stub :read_shaf_version, '3.0.0' do
          selected_versions = cmd.upgrade_packages.map { |u| u.version.to_s }
          assert_equal [], selected_versions
        end
      end
    end
  end

  describe "Upgrading an old project" do
    let(:tmp_dir) { Dir.mktmpdir }
    let(:project_path) { File.join(tmp_dir, '1.0.0_project') }

    before do
      project_tar = File.expand_path('../data/1.0.0_project.tar.gz', __dir__)
      Dir.chdir(tmp_dir) { `tar xzf #{project_tar}` }
      Dir.chdir(project_path) do
        Test.patch_gemfile_shaf_path
        Test.bundle_install
      end
    end

    after do
      FileUtils.remove_dir(tmp_dir)
    end

    it 'upgrades a 1.0.0 project to latest version' do
      Dir.chdir(project_path) do
        Test.exec_shaf("version") do |out, err|
          assert_equal '', err
          assert_match(/Installed Shaf version: #{VERSION}/, out)
          assert_match(/Project .* created with Shaf version: 1.0.0/, out)
        end

        Test.exec_shaf("upgrade") do |_, err|
          assert_equal '', err
        end

        expected_new_version = Upgrade::Package.all.last.version

        Test.exec_shaf("version") do |out, err|
          assert_equal '', err
          assert_match(/Installed Shaf version: #{VERSION}/, out)
          assert_match(/Project .* created with Shaf version: #{expected_new_version}/, out)
        end
      end
    end
  end
end
