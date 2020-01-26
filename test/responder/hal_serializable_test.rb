require 'test_helper'
require 'hal_presenter'

module Shaf
  module Responder
    describe HalSerializable do
      let(:mime_type) { 'application/hal+json' }

      let(:responder_class) do
        Class.new(Base) do
          include HalSerializable
        end
      end
      let(:responder) do
        responder_class.new(nil, nil)
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

      it '#lookup_rel' do
        response = Response.new(
          content_type: mime_type,
          body: nil,
          serialized_hash: serialized_response
        )
        links = responder.lookup_rel(:bar, response)

        _(links.size).must_equal 1
        _(links.first[:href]).must_equal 'https://foo.bar:443/bar'
        _(links.first[:as]).must_equal 'fetch'
        _(links.first[:crossorigin]).must_equal 'anonymous'
      end
    end
  end
end
