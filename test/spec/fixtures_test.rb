require 'test_helper'

module Shaf
  module Spec
    describe Fixtures do
      before do
        Fixture.define :items do
          item1 'one'
          item2 'two'
        end
        Fixture.define :orders do
          order1 [items(:item1), items(:item2)]
        end
      end

      after do
        Fixtures.clear
      end

      let(:obj) do
        klass = Class.new { include Fixtures::Accessors }
        klass.new
      end

      it 'can access items' do
        obj.must_respond_to :orders
        obj.orders.keys.must_equal([:order1])
      end

      it 'can access nested fixtures' do
        obj.orders(:order1).must_equal(%w[one two])
      end

      it 'raise exception when key does not exist' do
        lambda {
          obj.orders(:not_existing)
        }.must_raise Fixtures::FixtureNotFound
      end
    end
  end
end
