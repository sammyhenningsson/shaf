require 'test_helper'
require 'generator/stubbed_output'

module Shaf
  module Generator
    describe Policy do
      extend StubbedOutput

      let(:file) { "api/policies/blog_policy.rb" }

      describe "empty policy" do
        let(:generator) do
          Factory.create(*%w(policy blog))
        end

        it "creates file in api/policies" do
          assert_includes output.keys, file
        end

        it "declares the blog policy class inheriting from BaseSerializer" do
          assert_match %r(^class BlogPolicy < BasePolicy$), output[file]
        end

        it "requires base_policy" do
          assert_match %r(^\s*require 'policies/base_policy'), output[file]
        end
      end

      describe "model with properties" do
        let(:generator) do
          Factory.create(*%w(policy blog user_id message))
        end

        it "adds attributes" do
          assert_match %r(^\s*attribute :user_id$), output[file]
          assert_match %r(^\s*attribute :message$), output[file]
        end

      end
    end
  end
end
