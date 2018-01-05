require 'test_helper'

module Shaf
  describe Command do
    let(:command) do
      Class.new(Command::Base) do
        identifier "test_command"
        usage "do stuff"
      end
    end

    after do
      Command::Registry.unregister "test_command"
    end

    it "registers subclass" do
      count = Command::Registry.size
      command # trigger let block
      assert_equal count + 1, Command::Registry.size
    end

    it "identify with string" do
      expected = command
      assert_equal expected, Command::Registry.lookup("test_command")
      assert_nil Command::Registry.lookup("some invalid identifier")
    end

    it "::usage" do
      command # trigger let block
      assert_includes Command::Registry.usage, "do stuff"
    end
  end
end
