require 'test_helper'
require 'generator/stubbed_output'

module Shaf
  module Generator
    describe Model do
      extend StubbedOutput

      describe "empty model" do
        let(:generator) do
          Factory.create(*%w(model blog))
        end

        it "creates file in api/models" do
          assert_includes output.keys, "api/models/blog.rb"
        end

        it "creates a migration" do
          refute_empty output.keys.grep(/migrations\/.*create_blogs_table\.rb/)
        end

        it "generates a serializer" do
          assert_includes output.keys, "api/serializers/blog_serializer.rb"
        end

        it "generates a policy" do
          assert_includes output.keys, "api/policies/blog_policy.rb"
        end

        it "generates a forms" do
          assert_includes output.keys, "api/forms/blog_forms.rb"
        end

        it "inherits Sequel::Model" do
          assert_match %r(class Blog < Sequel::Model), output["api/models/blog.rb"]
        end
      end

      describe "empty model with namespace" do
        let(:file) { "api/models/foo/bar.rb" }
        let(:generator) do
          Factory.create(*%w(model foo/bar))
        end

        it "creates file in directory api/models/foo" do
          assert_includes output.keys, file
        end

        it "nests class under module" do
          assert_match(/module Foo\n  class Bar < Sequel::Model/m, output[file])
        end
      end
    end
  end
end
