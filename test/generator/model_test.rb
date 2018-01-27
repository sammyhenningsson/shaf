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

        it "creates file in app/models" do
          assert_includes output.keys, "app/models/blog.rb"
        end

        it "creates a migration" do
          refute_empty output.keys.grep(/migrations\/.*create_blogs_table\.rb/)
        end

        it "requires formable" do
          assert_match %r(\Arequire 'lib/formable'$), output["app/models/blog.rb"]
        end

        it "includes Formable" do
          assert_match %r(^\s*include Formable$), output["app/models/blog.rb"]
        end

        it "inherits Sequel::Model" do
          assert_match %r(class Blog < Sequel::Model), output["app/models/blog.rb"]
        end
      end

      describe "model with properties" do
        let(:generator) do
          Factory.create(*%w(model blog user_id:integer message:string:Inlägg))
        end

        it "declares a form" do
          assert_match %r(^\s*form do$), output["app/models/blog.rb"]
        end

        it "adds form fields" do
          assert_match(
            %r(^\s*field :user_id, type: "integer"$),
            output["app/models/blog.rb"],
            "Model file does not include: 'field :user_id, type \"integer\"'\n"
          )
          assert_match(
            %r(^\s*field :message, type: "string", label: "Inlägg"$),
            output["app/models/blog.rb"],
            "Model file does not include: 'field :message, type \"string\", label: \"Inlägg\"'\n"
          )
        end

        it "sets title and name for create form" do
          assert_match %r(^\s*create do$), output["app/models/blog.rb"]
          assert_match %r(^\s*title 'Create Blog'$), output["app/models/blog.rb"]
          assert_match %r(^\s*name  'create-blog'$), output["app/models/blog.rb"]
        end

        it "sets title and name for edit form" do
          assert_match %r(^\s*edit do$), output["app/models/blog.rb"]
          assert_match %r(^\s*title 'Update Blog'$), output["app/models/blog.rb"]
          assert_match %r(^\s*name  'update-blog'$), output["app/models/blog.rb"]
        end
      end
    end
  end
end
