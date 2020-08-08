# frozen_string_literal: true

require 'test_helper'

module Shaf
  describe Profile do
    let(:profile) do
      Class.new(Profile) do
        name 'test-profile'
      end
    end
    let(:logger) do
      mock = Minitest::Mock.new
      def mock.warn(msg); end
      mock
    end

    before do
      $logger = logger
    end

    after do
      Profiles.clear
    end

    it 'registers profile' do
      name = profile.name
      _(Profiles.find name).must_equal profile
    end

    it 'can add attributes' do
      profile.attribute('attr1', doc: 'doc for attr1', type: :string)
      profile.attribute(:attr2, doc: 'doc for attr2', type: :integer)

      attr1, attr2 = profile.attributes

      _(attr1.name).must_equal :attr1
      _(attr1.doc).must_equal 'doc for attr1'
      _(attr1.type).must_equal :string
      _(attr2.name).must_equal :attr2
      _(attr2.doc).must_equal 'doc for attr2'
      _(attr2.type).must_equal :integer
    end

    it 'can add rels' do
      profile.rel(
        'rel1',
        doc: 'doc for rel1',
        http_method: 'GET',
        content_type: 'application/hal+json'
      )

      profile.rel(
        'rel2',
        doc: 'doc for rel2',
        http_methods: ['GET', 'POST'],
        payload_type: 'application/json',
        content_type: 'application/hal+json'
      )

      rel1, rel2 = profile.relations

      _(rel1.name).must_equal :rel1
      _(rel1.doc).must_equal 'doc for rel1'
      _(rel1.http_methods).must_equal ['GET']
      _(rel1.payload_type).must_be_nil
      _(rel1.content_type).must_equal 'application/hal+json'

      _(rel2.name).must_equal :rel2
      _(rel2.doc).must_equal 'doc for rel2'
      _(rel2.http_methods).must_equal ['GET', 'POST']
      _(rel2.payload_type).must_equal 'application/json'
      _(rel2.content_type).must_equal 'application/hal+json'
    end

    it 'can add nested attributes' do
      profile.attribute('attr', doc: 'toplevel attribute', type: :array) do
        rel 'rel1', doc: 'nested rel1'
        attribute :attr1, doc: 'nested attribute1', type: :hash do
          rel 'rel2', doc: 'nested rel2'
          attribute :attr2, doc: 'nested attribute2', type: :string
        end
      end

      attr = profile.attributes.first

      _(attr.name).must_equal :attr
      _(attr.doc).must_equal 'toplevel attribute'
      _(attr.type).must_equal :array

      attr1 = attr.attributes.first

      _(attr1.name).must_equal :attr1
      _(attr1.doc).must_equal 'nested attribute1'
      _(attr1.type).must_equal :hash

      rel1 = attr.relations.first

      _(rel1.name).must_equal :rel1
      _(rel1.doc).must_equal 'nested rel1'

      attr2 = attr1.attributes.first

      _(attr2.name).must_equal :attr2
      _(attr2.doc).must_equal 'nested attribute2'
      _(attr2.type).must_equal :string

      rel2 = attr1.relations.first

      _(rel2.name).must_equal :rel2
      _(rel2.doc).must_equal 'nested rel2'
    end

    it 'can nest attributes inside relations' do
      profile.rel('rel', doc: 'toplevel rel') do
        rel 'rel1', doc: 'nested rel1'
        attribute :attr1, doc: 'nested attribute1', type: :hash do
          rel 'rel2', doc: 'nested rel2'
          attribute :attr2, doc: 'nested attribute2', type: :string
        end
      end

      rel = profile.relations.first

      _(rel.name).must_equal :rel
      _(rel.doc).must_equal 'toplevel rel'

      attr1 = rel.attributes.first

      _(attr1.name).must_equal :attr1
      _(attr1.doc).must_equal 'nested attribute1'
      _(attr1.type).must_equal :hash
      _(attr1.relations).must_be_empty

      attr2 = attr1.attributes.first

      _(attr2.name).must_equal :attr2
      _(attr2.doc).must_equal 'nested attribute2'
      _(attr2.type).must_equal :string

      logger.verify
    end
  end
end
