require 'test_helper'
require 'shaf/immutable_attr'

module Shaf
  describe ImmutableAttr do
    let(:clazz) do
      Class.new do
        extend ImmutableAttr

        def initialize(foo = nil)
          @foo = foo
        end
      end
    end

    it '#immutable_reader' do
      clazz.immutable_reader :foo

      obj = clazz.new('test')
      obj.foo << 'bar'
      assert_equal 'test', obj.foo
    end

    it '#immutable_writer' do
      clazz.immutable_writer :foo

      obj = clazz.new
      x = 'test'
      obj.foo = x
      x << 'bar'
      assert_equal 'test', obj.instance_variable_get(:@foo)
    end

    it '#immutable_accessor' do
      clazz.immutable_accessor :foo

      obj = clazz.new('test')
      obj.foo << 'bar'
      assert_equal 'test', obj.foo

      x = 'test2'
      obj.foo = x
      x << 'bar'
      assert_equal 'test2', obj.instance_variable_get(:@foo)
    end
  end
end
