require 'test_helper'

module Shaf
  describe Upgrade::Package do
    it "it can compare upgrades" do
      a = Upgrade::Package.new("1.1.0")
      b = Upgrade::Package.new("2.10.1")
      assert a < b
      refute a > b
      assert a == "1.1.0"
    end

    it "parses a tarball" do
      upgrade = Upgrade::Package.new("0.4.0")
      assert upgrade.load
      assert_equal(
        upgrade.to_s,
        "Shaf::Upgrade::Package for version 0.4.0, Add: 0, Del: 0, Patch: 2"
      )
    end
  end
end
