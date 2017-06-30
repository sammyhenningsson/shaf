$:.unshift '.'
require 'minitest/autorun'
require 'test/test_utils/payload'

class PayloadTest < Minitest::Test
  include TestUtils::Payload

  def setup
    @payload = {
      attr1: 1,
      attr2: 2,
      _links: {
        link1: {
          href: '/link1'
        },
        link2: {
          href: '/link2'
        }
      },
      _embedded: {
        embed1: {
          attr_e1: 'e1',
          _links: {
            link_e1: {
              href: '/links/e1'
            }
          },
          _embedded: {
            embed1a: {
              attr_e1a: 'e1a'
            }
          }
        },
        embed2: [
          {
            attr_embed2a: 'e2a',
            _links: {
              link_e2a: {
                href: 'links/e2a'
              }
            }
          },
          {
            attr_embed2b: 'e2b',
            _links: {
              link_e2b: {
                href: 'links/e2b'
              }
            }
          }
        ]
      }
    }
  end

  #TODO How to verify that we do get assertions

  def test_links
    assert_link :link1, '/link1'
    assert_link :link2, '/link2'
  end

  def test_embedded_without_block
    assert_equal @payload[:_embedded], embedded
    assert_equal @payload[:_embedded][:embed1], embedded(:embed1)
  end

  def test_embedded_with_block
    embedded :embed1 do
      assert_attribute :attr_e1, 'e1'
      assert_link :link_e1, '/links/e1'

      embedded :embed1a do
        assert_attribute :attr_e1a, 'e1a'
      end
    end
  end
end
