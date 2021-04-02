# frozen_string_literal: true

require 'test_helper'

module Shaf
  module ALPS
    describe JsonSerializer do
      let(:ext_href) { 'https://gist.github.com/sammyhenningsson/2103d839eb79a7baf8854bfb96bda7ae' }
      let(:profile) do
	Class.new(Profile) do
	  name 'test-profile'

	  rel(:real, doc: 'toplevel relation', http_methods: 'GET') do
	    attribute :rel_attr, doc: 'attribute on link relation', type: :string
	  end

	  attribute('attr', doc: 'toplevel attribute', type: :array) do
	    rel 'rel1', doc: 'nested rel1', http_methods: ['GET', 'PUT']
	    attribute :attr1, doc: 'nested attribute1', type: :hash do
	      rel 'rel2', doc: 'nested rel2', http_methods: ['PUT', 'POST']
	      attribute :attr, doc: 'nested attribute2', type: :string
	    end
	  end
	end
      end

      after do
	Profiles.unregister(profile)
      end

      it 'sets version to 1.0' do
	hash = JsonSerializer.call(profile)
	version = hash.dig(:alps, :version)

	_(version).must_equal('1.0')
      end

      it 'the top level has two descriptors' do
	hash = JsonSerializer.call(profile)
	descriptors = hash.dig(:alps, :descriptor)
	_(descriptors.size).must_equal 2
      end

      it 'the top level has one link relation descriptor' do
	hash = JsonSerializer.call(profile)
	relation = hash.dig(:alps, :descriptor).find { |desc| desc[:id] == 'real' }

	_(relation).must_equal(
	  {
	    id: 'real',
	    name: 'real',
	    type: 'safe',
	    doc: {
	      value: 'toplevel relation'
	    },
	    ext: [
	      {
		id: :http_method,
		href: ext_href,
		value: ["GET"]
	      }
	    ],
	    descriptor: [
	      {
		id: 'rel_attr',
		name: 'rel_attr',
		type: 'semantic',
		doc: {
		  value: 'attribute on link relation'
		}
	      }
	    ]
	  }
	)
      end

      it 'the top level has one attribute descriptor' do
	hash = JsonSerializer.call(profile)
	attribute = hash.dig(:alps, :descriptor).find { |desc| desc[:id] == 'attr' }


	_(attribute[:name]).must_equal('attr')
	_(attribute[:type]).must_equal('semantic')
	_(attribute[:doc]).must_equal({value: 'toplevel attribute'})
      end

      it 'attribute attr has nested descriptors' do
	hash = JsonSerializer.call(profile)
	descriptors = hash.dig(:alps, :descriptor)
	  .find { |desc| desc[:id] == 'attr' }
	  .dig(:descriptor)
	_(descriptors.size).must_equal 2

	attribute =  descriptors.find { |desc| desc[:id] == 'attr1' }
	relation =  descriptors.find { |desc| desc[:id] == 'rel1' }

	_(relation).must_equal(
	  {
	    id: 'rel1',
	    name: 'rel1',
	    type: 'idempotent',
	    doc: {
	      value: 'nested rel1'
	    },
	    ext: [
	      {
		id: :http_method,
		href: ext_href,
		value: ["GET", "PUT"]
	      }
	    ]
	  }
	)

	_(attribute).must_equal(
	  {
	    id: 'attr1',
	    name: 'attr1',
	    type: 'semantic',
	    doc: {
	      value: 'nested attribute1'
	    },
	    descriptor: [
	      {
		id: 'attr1_attr',
		name: 'attr',
		type: 'semantic',
		doc: {
		  value: 'nested attribute2'
		},
	      },
	      {
		id: 'rel2',
		name: 'rel2',
		type: 'unsafe',
		doc: {
		  value: 'nested rel2'
		},
		ext: [
		  {
		    id: :http_method,
		    href: ext_href,
		    value: ["PUT", "POST"]
		  }
		]
	      }
	    ]
	  }
	)
      end
    end
  end
end
