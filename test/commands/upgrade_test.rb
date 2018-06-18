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

  describe "Upgrading an old project" do
    let(:tmp_dir) { Dir.mktmpdir }
    let(:project_path) { File.join(tmp_dir, 'old_project') }
    let(:project_tar) do
      File.expand_path('../../data/0.3.1_project.tar.gz', __FILE__)
    end

    before do
      Dir.chdir(tmp_dir) { `tar xzf #{project_tar}` }
    end

    after do
      FileUtils.remove_dir(tmp_dir)
    end

    it 'upgrades a 0.3.1 project to latest version' do
      Dir.chdir(project_path) do
        assert Test.system("shaf upgrade", out: File::NULL)
      end
    end
  end
end
