require 'test_helper'
require 'generator/stubbed_output'

module Shaf
  module Generator
    describe Scaffold do
      extend StubbedOutput

      let(:change_file_stub) do
        ->(file, &block) {
          File.open(file, 'w') { |f| f.puts "modified file" }
        }
      end

      let(:subject) do
        FileTransactions::ChangeFileCommand.stub :execute, change_file_stub do
          generator.call
        end
      end

      let(:generator) do
        Factory.create(*%w(scaffold book title:string pages:integer))
      end

      it "creates a controller" do
        assert_includes output.keys, "api/controllers/books_controller.rb"
      end

      it "creates a model" do
        assert_includes output.keys, "api/models/book.rb"
      end

      it "creates a migration" do
        refute_empty output.keys.grep(/migrations\/.*create_books_table\.rb/)
      end

      it "generates a serializer" do
        assert_includes output.keys, "api/serializers/book_serializer.rb"
      end

      it "generates a policy" do
        assert_includes output.keys, "api/policies/book_policy.rb"
      end

      it "generates a forms" do
        assert_includes output.keys, "api/forms/book_forms.rb"
      end

      describe "scaffold with namespace" do
        let(:generator) do
          Factory.create(*%w(scaffold api/book title:string pages:integer))
        end

        it "creates a controller" do
          assert_includes output.keys, "api/controllers/api/books_controller.rb"
        end

        it "creates a model" do
          assert_includes output.keys, "api/models/api/book.rb"
        end

        it "creates a migration" do
          refute_empty output.keys.grep(/migrations\/.*create_api_books_table\.rb/)
        end

        it "generates a serializer" do
          assert_includes output.keys, "api/serializers/api/book_serializer.rb"
        end

        it "generates a policy" do
          assert_includes output.keys, "api/policies/api/book_policy.rb"
        end

        it "generates a forms" do
          assert_includes output.keys, "api/forms/api/book_forms.rb"
        end
      end

      describe "it can skip generating a model" do
        let(:generator) do
          Factory.create(*%w(scaffold book title:string pages:integer), skip_model: true)
        end

        it "creates a controller but no model or migration" do
          assert_includes output.keys, "api/controllers/books_controller.rb"
          refute_includes output.keys, "api/models/book.rb"
          assert_empty output.keys.grep(/migrations\/.*create_books_table\.rb/)
        end
      end
    end
  end
end
