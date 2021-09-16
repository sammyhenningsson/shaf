require 'test_helper'
require 'generator/stubbed_output'

module Shaf
  module Generator
    describe Serializer do
      extend StubbedOutput

      let(:file) { "api/serializers/blog_serializer.rb" }
      describe "empty serializer" do
        let(:generator) do
          Factory.create(*%w(serializer blog))
        end

        it "creates file in api/serializers" do
          assert_includes output.keys, file
        end

        it "requires base_serializer and policy" do
          assert_match %r(^\s*require 'serializers/base_serializer'), output[file]
          assert_match %r(^\s*require 'policies/blog_policy'), output[file]
        end

        it "inherits from BaseSerializer" do
          assert_match %r(^class BlogSerializer < BaseSerializer$), output[file]
        end
      end

      describe "empty serializer with namespace" do
        let(:file) { "api/serializers/foo/bar_serializer.rb" }
        let(:generator) do
          Factory.create(*%w(serializer foo/bar))
        end

        it "creates file in directory api/serializers/foo" do
          assert_includes output.keys, file
        end

        it "nests class under module" do
          assert_match(/module Foo\n  class BarSerializer < BaseSerializer/m, output[file])
        end
      end

      describe "serializer with attributes" do
        let(:generator) do
          Factory.create(*%w(serializer blog user message))
        end

        it "specifies attributes" do
          assert_match %r(^\s*attribute :user), output[file]
          assert_match %r(^\s*attribute :message), output[file]
        end
      end
    end
  end
end
