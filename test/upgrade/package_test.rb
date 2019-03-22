require 'test_helper'

module Shaf
  describe Upgrade::Package do
    let(:to_patch) do
      {'0123456789abcdef' => 'some/file.rb' }
    end

    let(:to_add) do
      {'0123456789abcdef' => 'new/directories/foo' }
    end

    let(:to_drop) do
      [
        'some_.*_file.rb',
        'some/file.rb'
      ]
    end
    let(:to_substitute) do
      {'sub1' => 'some/file.rb'}
    end

    let(:project_files) do
      [
        'some/dir/some/file.rb',
        'foo/some_file.rb',
        'bar/some_other_file.rb'
      ]
    end

    let(:applied_patches) { {} }
    let(:apply_patch_stub) do
      lambda do |file, content|
        applied_patches[file] = content
      end
    end

    let(:applied_substitutes) { {} }
    let(:apply_substitute_stub) do
      lambda do |file, params|
        applied_substitutes[file] = params
      end
    end

    let(:added_files) { {} }
    let(:file_open_stub) do
      mock = Minitest::Mock.new
      def mock.write(content); content; end
      lambda do |file, _flags, &block|
        added_files[file] = block.call(mock)
      end
    end

    let(:unlinks) { [] }
    let(:unlink_stub) do
      lambda do |file|
        unlinks << file
      end
    end

    it 'it can compare upgrades' do
      a = Upgrade::Package.new('1.1.0')
      b = Upgrade::Package.new('2.10.1')
      assert a < b
      refute a > b
      assert a == '1.1.0'
    end

    it 'parses a tarball' do
      package = Upgrade::Package.new('0.4.0')
      assert package.load
      assert_equal(
        'Shaf::Upgrade::Package for version 0.4.0 (Add: 0, Del: 0, Patch: 2, Regexp: 0)',
        package.to_s
      )
    end

    it '#parse_manifest' do
      manifest = {
        'target_version' => '1.2.3',
        'patches'        => {'cd5b0bf61070a9fd57e60c45e9aaf64a' => 'config/database.rb'},
        'add'            => {'8ece24b8c440675bd3d188155909431c' => 'file/to/add.rb'},
        'drop'           => ['file/to/remove2.rb', 'file/to/remove2.rb'],
        'substitutes'    => {'d3b07384d113edec49eaa6238ad5ff00' => 'api/models/.*.rb'}
      }
      package = Upgrade::Package.new('1.2.3')
      package.send(:parse_manifest, manifest.to_yaml)
      assert_equal(
        package.to_s,
        'Shaf::Upgrade::Package for version 1.2.3 (Add: 1, Del: 2, Patch: 1, Regexp: 1)'
      )
    end

    it 'patches files' do
      manifest = Upgrade::Manifest.new(target_version: '2.0.0', patches: to_patch)
      package = Upgrade::Package.new(
        '2.0.0',
        manifest,
        {'0123456789abcdef' => 'some_patch_data'}
      )

      package.stub :files_in, project_files do
        package.stub :apply_patch, apply_patch_stub do
          package.apply
        end
      end

      assert_equal(
        { 'some/dir/some/file.rb' => 'some_patch_data'},
        applied_patches
      )
    end

    it 'adds files and directories' do
      manifest = Upgrade::Manifest.new(target_version: '2.0.0', add: to_add)
      package = Upgrade::Package.new('2.0.0', manifest, {'0123456789abcdef' => 'some_added_data'})

      Mutable.suppress_output do
        FileUtils.stub :mkdir_p, true do
          File.stub :open, file_open_stub do
            package.apply
          end
        end
      end

      assert_equal(
        { 'new/directories/foo' => 'some_added_data'},
        added_files
      )
    end

    it 'drops files' do
      manifest = Upgrade::Manifest.new(target_version: '2.0.0', drop: to_drop)
      package = Upgrade::Package.new('2.0.0', manifest)

      Mutable.suppress_output do
        package.stub :files_in, project_files do
          File.stub :unlink, unlink_stub do
            package.apply
          end
        end
      end

      assert_equal(
        ['some/dir/some/file.rb', 'bar/some_other_file.rb'],
        unlinks
      )
    end

    it 'applies substitute changes to files' do
      manifest = Upgrade::Manifest.new(
        target_version: '2.0.0',
        substitutes: to_substitute
      )
      package = Upgrade::Package.new('2.0.0', manifest)

      Mutable.suppress_output do
        package.stub :files_in, project_files do
          package.stub :apply_substitute, apply_substitute_stub do
            YAML.stub :safe_load, pattern: :foo, replace: :bar do
              package.apply
            end
          end
        end
      end

      assert_equal(
        {'some/dir/some/file.rb' => {pattern: :foo, replace: :bar}},
        applied_substitutes
      )
    end
  end
end
