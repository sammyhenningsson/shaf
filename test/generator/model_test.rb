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

        it "includes Formable" do
          assert_match %r(^\s*include Shaf::Formable$), output["api/models/blog.rb"]
        end

        it "inherits Sequel::Model" do
          assert_match %r(class Blog < Sequel::Model), output["api/models/blog.rb"]
        end
      end

      describe "model with properties" do
        let(:generator) do
          Factory.create(*%w(model blog user_id:integer message:string:Inlägg))
        end

        it "declares a form" do
          assert_match %r(^\s*form do$), output["api/models/blog.rb"]
        end

        it "adds form fields" do
          assert_match(
            %r(^\s*field :user_id, type: "integer"$),
            output["api/models/blog.rb"],
            "Model file does not include: 'field :user_id, type \"integer\"'\n"
          )
          assert_match(
            %r(^\s*field :message, type: "string", label: "Inlägg"$),
            output["api/models/blog.rb"],
            "Model file does not include: 'field :message, type \"string\", label: \"Inlägg\"'\n"
          )
        end

        it "sets title and name for create form" do
          assert_match %r(^\s*create do$), output["api/models/blog.rb"]
          assert_match %r(^\s*title 'Create Blog'$), output["api/models/blog.rb"]
          assert_match %r(^\s*name  'create-blog'$), output["api/models/blog.rb"]
        end

        it "sets title and name for edit form" do
          assert_match %r(^\s*edit do$), output["api/models/blog.rb"]
          assert_match %r(^\s*title 'Update Blog'$), output["api/models/blog.rb"]
          assert_match %r(^\s*name  'update-blog'$), output["api/models/blog.rb"]
        end
      end
    end
  end
end
