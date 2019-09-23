require 'test_helper'
require 'ostruct'

module Shaf
  describe Utils do
    it '::deep_symbolize_keys' do
      _(
        Utils.deep_symbolize_keys(
          'foo' => {
            'bar': 3,
            'baz' => [
              2,
              3,
              [{'x' => 'y'}],
              {'z' => {'w' => 4}}
            ]
          },
          more: {'stuff' => 'hello'}
        )
      ).must_equal(
        foo: {
          bar: 3,
          baz: [
            2,
            3,
            [{x: 'y'}],
            {z: {w: 4}}
          ]
        },
        more: {stuff: 'hello'}
      )
    end
  end
end
