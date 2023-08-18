require 'test_helper'
require 'ostruct'
require 'hal_presenter'

module Shaf
  module Responder
    describe Html do
      let(:mime_type) { 'text/html' }
      let(:resource)  { OpenStruct.new(name: 'bengt') }
      let(:mock_controller) do
        mock = Minitest::Mock.new
        def mock.content_type(*); nil; end
        def mock.body(content); content; end
        def mock.erb(_template, locals:)
          "<html>#{JSON.generate(locals[:serialized])}</html>"
        end
        def mock.request_headers; {}; end
        def mock.etag_for(_payload); 'mocked_etag'; end
        mock
      end

      let(:serializer) do
        Class.new do
          extend HALPresenter
          profile 'gulo'
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
        _(Html.mime_type).must_equal mime_type
      end

      it 'serializes response' do
        mock_controller.expect :headers, {}
        response = Html.call(mock_controller, resource, serializer: serializer)

        _(response).must_equal '<html>{"name":"Bengt"}</html>'
      end

      it 'preloads links' do
        hash = {}
        mock_controller.expect :headers, hash # One time for getting the Link header
        mock_controller.expect :headers, hash # And one time for setting the Link header
        mock_controller.expect :headers, hash # And another time for rendering headers in view

        serializer.stub :to_hal, serialized_response do
          Html.call(mock_controller, resource, serializer: serializer, preload: :bar)

          _(hash['Link']).must_equal '</bar>; rel=preload; as=fetch; crossorigin=anonymous'
          mock_controller.verify
        end
      end

      it 'adds headers' do
        mock_controller.expect :headers, {'X-Custom-A' => 'hello'}

        expected_erb_locals = {
          request_headers: {},
          response_headers: {
            'X-Custom-A' => 'hello',
            'Content-Type' => 'application/hal+json; profile="gulo"',
            'ETag' => '"mocked_etag"'
          },
          serialized: {name: 'Bengt'}
        }

        class << mock_controller
          remove_method :erb
        end
        mock_controller.expect :erb, nil, [:payload], locals: expected_erb_locals

        Html.call(mock_controller, resource, serializer: serializer)

        mock_controller.verify
      end
    end
  end
end
