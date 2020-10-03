require 'test_helper'
require 'ostruct'

module Shaf
  module Parser
    describe Json do
      it '::mime_type' do
        _(Json.mime_type).must_equal 'application/json'
      end

      it '::can_handle?' do
        [
          'application/json',
          'application/hal+json',
          'application/vnd.foobar+json'
        ].each do |content_type|
          _(Json.can_handle? OpenStruct.new(content_type: content_type)).must_equal true
        end

        _(Json.can_handle? OpenStruct.new(content_type: 'application/html')).must_equal false
      end

      it '#call' do
        body = Json.new(request: nil, body: '{"a": 1, "b": "foo"}').call

        _(body).must_equal(
          {
            a: 1,
            b: 'foo'
          }
        )
      end

      it '#call' do
        parser = Json.new(request: nil, body: '{"a": 1, ]')

        _ { parser.call }.must_raise(Parser::Error)
      end
    end
  end
end
