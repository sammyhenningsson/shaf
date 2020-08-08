require 'test_helper'
require 'generator/stubbed_output'

module Shaf
  module Generator
    describe Policy do
      extend StubbedOutput

      let(:file) { "api/profiles/book.rb" }

      let(:generator) do
        Factory.create(*%w(profile book))
      end

      it "creates file in api/profiles" do
        assert_includes output.keys, file
      end

      it "declares the book profile class inheriting from Shaf::Profile" do
        assert_match %r(^module Profiles$), output[file]
        assert_match %r(^\s*class Book < Shaf::Profile$), output[file]
      end

      it "uses the delete relation from shaf-basic" do
        assert_match %r(use :delete, from: Shaf::Profiles::ShafBasic), output[file]
      end
    end
  end
end
