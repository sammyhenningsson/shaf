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
    let(:manifest) do
      Upgrade::Manifest.new(
        target_version: "0.0.1",
        patches: patches,
        add: add,
        drop: drop
      )
    end

    it "returns checksum for mathching files" do
      assert_equal "change", manifest.patch_for("/home/dev/some/file.rb")
      assert_nil manifest.patch_for("/home/dev/some/other/file.rb")
    end

    it "#files return all file" do 
      assert_equal(
        %i(patch add drop),
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
  end
end
