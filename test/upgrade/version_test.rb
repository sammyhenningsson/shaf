require 'test_helper'

module Shaf
  describe Upgrade::Version do
    it "raises exception when version has wrong pattern" do
      assert_raises Upgrade::Version::UpgradeVersionError do
        Upgrade::Version.new("foo.bar")
      end
    end

    it "can sort upgrades" do
      a = Upgrade::Version.new("10.1.0")
      b = Upgrade::Version.new("1.1.0")
      c = Upgrade::Version.new("2.10.1")
      d = Upgrade::Version.new("2.1.0")
      e = Upgrade::Version.new("2.0.3")
      f = Upgrade::Version.new("3.1.0")
      g = Upgrade::Version.new("3.1.2")
      assert_equal [b, e, d, c, f, g, a], [a, b, c, d, e, f, g].sort
    end

    it "it can compare upgrades" do
      a = Upgrade::Version.new("1.1.0")
      b = Upgrade::Version.new("2.10.1")
      assert a < b
      refute a > b
    end

    it "upgrades with same version are considered equal" do
      a = Upgrade::Version.new("1.1.0")
      b = Upgrade::Version.new("2.10.1")
      c = Upgrade::Version.new("2.10.1")
      assert a != b
      assert b == c
    end

    it "it can compare upgrades to version strings" do
      a = Upgrade::Version.new("1.1.0")
      assert a < "2.0.0"
      assert a > "1.0.5"
      assert a == "1.1.0"
    end

    it "it can be initialized with another version instance" do
      a = Upgrade::Version.new("1.1.0")
      b = Upgrade::Version.new(a)
      assert b ==  "1.1.0"
      assert a == a
      refute a.equal? b
    end
  end
end
