require 'test_helper'
require 'generator/stubbed_output'

module Shaf
  module Generator
    describe Forms do
      extend StubbedOutput

      describe 'the forms file' do
        let(:generator) do
          Factory.create(*%w(forms blog))
        end

        it 'creates file in api/forms' do
          assert_includes output.keys, "api/forms/blog_forms.rb"
        end

        it 'extends Formable' do
          assert_match %r(^\s*extend Shaf::Formable$), output['api/forms/blog_forms.rb']
        end
      end

      describe 'forms with fields' do
        let(:generator) do
          Factory.create(*%w(forms blog user_id:integer message:string:Inlägg))
        end

        it "declares a form" do
          assert_match %r(^\s*forms_for\(Blog\) do$), output['api/forms/blog_forms.rb']
        end

        it "adds form fields" do
          assert_match(
            %r(^\s*field :user_id, type: "integer"$),
            output['api/forms/blog_forms.rb'],
            "Model file does not include: 'field :user_id, type \"integer\"'\n"
          )
          assert_match(
            %r(^\s*field :message, type: "string", label: "Inlägg"$),
            output['api/forms/blog_forms.rb'],
            "Model file does not include: 'field :message, type \"string\", label: \"Inlägg\"'\n"
          )
        end

        it "sets title and name for create form" do
          assert_match %r(^\s*create do$), output['api/forms/blog_forms.rb']
          assert_match %r(^\s*title 'Create Blog'$), output['api/forms/blog_forms.rb']
          assert_match %r(^\s*name  'create-blog'$), output['api/forms/blog_forms.rb']
        end

        it "sets title and name for edit form" do
          assert_match %r(^\s*edit do$), output['api/forms/blog_forms.rb']
          assert_match %r(^\s*title 'Update Blog'$), output['api/forms/blog_forms.rb']
          assert_match %r(^\s*name  'update-blog'$), output['api/forms/blog_forms.rb']
        end
      end
    end
  end
end
