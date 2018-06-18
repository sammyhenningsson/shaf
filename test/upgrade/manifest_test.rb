require 'test_helper'

module Shaf
  describe Upgrade::Manifest do
    let(:patches) { {"foo" => "some/file.rb"} }
    let(:manifest) do
      Upgrade::Manifest.new(target_version: "0.0.1", patches: patches)
    end

    it "returns checksum for mathching files" do
      assert_equal "foo", manifest.patch_name_for("/home/dev/some/file.rb")
      assert_nil manifest.patch_name_for("/home/dev/some/other/file.rb")
    end
  end
end
