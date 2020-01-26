require 'test_helper'
require 'ostruct'
require 'hal_presenter'

module Shaf
  module Responder
    describe Hal do
      let(:mime_type) { 'application/hal+json' }
      let(:resource)  { OpenStruct.new(name: 'bengt') }
      let(:mock_controller) do
        mock = Minitest::Mock.new
        def mock.content_type(*); nil; end
        def mock.body(content); content; end
        mock
      end

      let(:serializer) do
        Class.new do
          extend HALPresenter
          attribute :name do
            resource.name.capitalize
          end
        end
      end
      let(:serialized_response) do
        {
          _links: {
            foo: {
              href: 'https://foo.bar:443/foo'
            },
            bar: {
              href: 'https://foo.bar:443/bar'
            },
            baz: {
              href: 'https://foo.bar:443/baz'
            }
          }
        }
      end

      it '::mime_type' do
        _(Hal.mime_type).must_equal mime_type
      end

      it 'serializes response' do
        response = Hal.call(mock_controller, resource, serializer: serializer)

        _(response).must_equal '{"name":"Bengt"}'
      end

      it 'preloads links' do
        hash = {}
        mock_controller.expect :headers, hash # One time for getting the Link header
        mock_controller.expect :headers, hash # And one time for setting the Link header

        serializer.stub :to_hal, serialized_response do
          Hal.call(mock_controller, resource, serializer: serializer, preload: :bar)

          _(hash['Link']).must_equal '</bar>; rel=preload; as=fetch; crossorigin=anonymous'
          mock_controller.verify
        end
      end
    end
  end
end
