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
      Command::Factory.unregister "test_command"
    end

    it "registers subclass" do
      count = Command::Factory.size
      command # trigger let block
      assert_equal count + 1, Command::Factory.size
    end

    it "identify with string" do
      expected = command
      assert_equal expected, Command::Factory.lookup("test_command")
      assert_nil Command::Factory.lookup("some invalid identifier")
    end

    it "::usage" do
      command # trigger let block
      assert_includes Command::Factory.usage, "do stuff"
    end
  end
end
