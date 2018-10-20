require 'shaf/spec/fixtures'
require 'shaf/utils'

module Shaf
  module Spec
    class Fixture

      include Fixtures::Accessors

      attr_reader :name

      def self.define(name, &block)
        return unless block_given?
        Fixtures.fixture_defined new(name.to_sym, block)
      end

      def initialize(name, block)
        @name = name
        @block = block
      end

      def init
        instance_exec(&@block)
        self
      end

      def add_entry(entry_name, resrc = nil, &block)
        value = block ? instance_exec(&block) : resrc
        fixtures = send(name)
        fixtures[entry_name] = value
      end

      private

      def method_missing(method, *args, &block)
        return super unless resource_name?(args.size, block_given?)
        add_entry(method, args.first, &block)
      end

      def respond_to_missing?(*)
        true
      end

      def nested_fixture?(*args)
        args.size == 1 && args.first.is_a?(Symbol)
      end

      def resource_name?(arg_count, block_given)
        arg_count += 1 if block_given
        arg_count == 1
      end
    end
  end
end
