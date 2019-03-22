require 'test_helper'

module Shaf
  describe Upgrade::Manifest do
    let(:patches) { {"change" => "some/file.rb"} }
    let(:add) do
      {
        "add1" => "add/some/file1.rb",
        "add2" => "add/some/file2.rb"
      }
    end
    let(:drop) do
      [
        "drop/some/file1.rb",
        "drop/some/file2.rb"
      ]
    end
    let(:substitutes) do
      {
        "sub1" => "some/file.rb",
        "sub2" => "ome/f....rb",
      }
    end
    let(:manifest) do
      Upgrade::Manifest.new(
        target_version: "0.0.1",
        patches: patches,
        substitutes: substitutes,
        add: add,
        drop: drop
      )
    end

    it "returns checksums for mathching patch files" do
      assert_equal ["change"], manifest.patches_for("/home/dev/some/file.rb")
      assert_empty manifest.patches_for("/home/dev/some/other/file.rb")
    end

    it 'returns checksums for mathching regexp files' do
      assert_equal %w[sub1 sub2], manifest.regexps_for('/home/dev/some/file.rb')
      assert_empty manifest.regexps_for('/home/dev/some/other/file.rb')
    end

    it "#files return all file" do 
      assert_equal(
        %i(patch add drop regexp),
        manifest.files.keys
      )
    end
    
    it "#files return all patches" do 
      assert_equal(
        %w(change),
        manifest.files[:patch].keys
      )
    end
    
    it "#files return all files to add" do 
      assert_equal(
        %w(add1 add2),
        manifest.files[:add].keys
      )
    end
    
    it "#files return all files to remove" do 
      manifest.files[:drop].each do |pattern|
        assert("drop/some/file1.rb" =~ pattern || "drop/some/file2.rb" =~ pattern)
      end
    end

    it "#drop?" do
      assert manifest.drop?("drop/some/file1.rb")
      assert manifest.drop?("nested/dir/drop/some/file2.rb")
      refute manifest.drop?("some/file.rb")
    end
  end
end
