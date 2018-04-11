require 'test_helper'

module Shaf
  describe Command do
    let(:command_class) do
      Class.new(Command::Base) do
        identifier "test_command"
        usage "do stuff"

        def self.options(parser, options)
          parser.on("-f", "--foo") do |n|
            options[:foo] = n
          end

          parser.on("-b", "--bar BAR") do |b|
            options[:bar] = b
          end

          parser.on("-z", "--baz NUM", Integer) do |b|
            options[:baz] = b
          end
        end
      end
    end

    after do
      Command::Factory.unregister "test_command"
    end

    it "registers subclass" do
      count = Command::Factory.size
      command_class # trigger let block
      assert_equal count + 1, Command::Factory.size
    end

    it "identify with string" do
      expected = command_class
      assert_equal expected, Command::Factory.lookup("test_command")
      assert_nil Command::Factory.lookup("some invalid identifier")
    end

    it "Factory::usage" do
      command_class # trigger let block
      assert_includes Command::Factory.usage, "do stuff"
    end

    it "Factory::create" do
      command_class # trigger let block
      command = Command::Factory.create(
        "test_command",
        "-f",
        "--bar", "baz",
        "-z", "5",
        "cmd_arg1",
        "cmd_arg2"
      )
      assert_equal [:foo, :bar, :baz].sort, command.options.keys.sort
      assert_equal "baz", command.options[:bar]
      assert_equal 5, command.options[:baz]
      assert_equal ["cmd_arg1", "cmd_arg2"], command.args
    end
  end
end
