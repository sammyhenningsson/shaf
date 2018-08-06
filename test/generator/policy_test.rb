require 'test_helper'

module Shaf
  module Generator
    describe Policy do
      let(:output) { {} }

      let(:write_stub) do
        lambda do |file, content|
          output[file] = content
        end
      end

      before do
        File.stub :write, write_stub do
          Dir.stub :exist?, true do
            Mutable.suppress_output { generator.call }
          end
        end
      end

      describe "empty policy" do
        let(:file) { "api/policies/blog_policy.rb" }
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
          assert_match %r(^\s*require 'policies/base_policy'), output["api/policies/blog_policy.rb"]
        end
      end

      describe "model with properties" do
        let(:file) { "api/policies/blog_policy.rb" }
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
