require 'test_helper'
require 'generator/stubbed_output'

module Shaf
  module Generator
    describe Serializer do
      extend StubbedOutput

      describe "empty serializer" do
        let(:generator) do
          Factory.create(*%w(serializer blog))
        end

        it "creates file in api/serializers" do
          assert_includes output.keys, "api/serializers/blog_serializer.rb"
        end

        it "requires base_serializer and policy" do
          assert_match %r(^\s*require 'serializers/base_serializer'), output["api/serializers/blog_serializer.rb"]
          assert_match %r(^\s*require 'policies/blog_policy'), output["api/serializers/blog_serializer.rb"]
        end

        it "inherits from BaseSerializer" do
          assert_match %r(^class BlogSerializer < BaseSerializer$), output["api/serializers/blog_serializer.rb"]
        end
      end

      describe "serializer with attributes" do
        let(:generator) do
          Factory.create(*%w(serializer blog user message))
        end

        it "specifies attributes" do
          assert_match %r(^\s*attribute :user), output["api/serializers/blog_serializer.rb"]
          assert_match %r(^\s*attribute :message), output["api/serializers/blog_serializer.rb"]
        end
      end
    end
  end
end
