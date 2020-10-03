require 'test_helper'
require 'rack/request'

module Shaf
  module Parser
    describe FormData do
      def mock_request(content_type:, body: nil)
        Rack::Request.new(
          'rack.input' =>  StringIO.new("#{body}\n"),
          'CONTENT_TYPE' => content_type
        )
      end

      it '::can_handle?' do
        [
          mock_request(content_type: 'application/x-www-form-urlencoded'),
          mock_request(content_type: 'multipart/form-data'),
        ].each do |request|
          _(FormData.can_handle? request).must_equal true
        end

        request = mock_request(content_type: 'application/json')
        _(FormData.can_handle? request).must_equal false
      end

      it '#call' do
        body = 'a=1&b=foo'
        request = Rack::Request.new(
          'rack.input' =>  StringIO.new(body),
          'CONTENT_TYPE' => 'application/x-www-form-urlencoded'
        )

        body = FormData.new(request: request, body: body).call

        _(body).must_equal(
          {
            'a' => "1",
            'b' => 'foo'
          }
        )
      end
    end
  end
end
