require 'test_helper'

module Shaf
  module Generator
    describe Model do
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
    end
  end
end
