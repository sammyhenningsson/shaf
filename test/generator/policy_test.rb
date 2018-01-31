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
        let(:file) { "app/policies/blog.rb" }
        let(:generator) do
          Factory.create(*%w(policy blog))
        end

        it "creates file in app/policies" do
          assert_includes output.keys, file
        end

        it "declares the blog policy class" do
          assert_match %r(^class BlogPolicy$), output[file]
        end

        it "includes HALPresenter::Policy::DSL" do
          assert_match %r(^\s*include HALPresenter::Policy::DSL$), output[file]
        end
      end

      describe "model with properties" do
        let(:file) { "app/policies/blog.rb" }
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
