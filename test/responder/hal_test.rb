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
        def mock.body(content); content; end
        def mock.content_type(value = nil)
          @content_type = value if value
          @content_type
        end
        mock
      end

      let(:serializer) do
        Class.new(Serializer) do
          attribute :name do
            resource.name.capitalize
          end

          profile :foo

          # Override these uri helpers
          def self.profile_uri(_name)
            'http://foo.bar/profile/foo'
          end

          def self.doc_curie_uri(_name)
            'http://foo.bar/curie/foo{#rel}'
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

        _(JSON.parse(response)).must_equal(
          {
            'name' => 'Bengt',
            '_links' => {
              'profile' => {
                'href' => "http://foo.bar/profile/foo"
              },
              'curies' => [
                {
                  'name' => 'doc',
                  'href' => "http://foo.bar/curie/foo{#rel}",
                  'templated' => true
                  }
              ]
            }
          }
        )
      end

      it 'specifies a mediatype profile with URI' do
        Hal.call(mock_controller, resource, serializer: serializer)

        _(mock_controller.content_type).must_equal 'application/hal+json; profile="http://foo.bar/profile/foo"'
      end

      it 'specifies a mediatype profile' do
        form_serializer = Class.new(serializer)
        form_serializer.profile 'shaf-form'

        Hal.call(mock_controller, resource, serializer: form_serializer)

        _(mock_controller.content_type).must_equal 'application/hal+json; profile="urn:shaf:form"'
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
