require 'test_helper'

module Shaf
  module Generator
    describe Serializer do
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

      describe "empty serializer" do
        let(:generator) do
          Factory.create(*%w(serializer blog))
        end

        it "creates file in app/serializers" do
          assert_includes output.keys, "app/serializers/blog.rb"
        end

        it "requires policy" do
          assert_match %r(^\s*require 'policies/), output["app/serializers/blog.rb"]
        end

        it "extends HALPresenter" do
          assert_match %r(^\s*extend HALPresenter$), output["app/serializers/blog.rb"]
        end

        it "extends UriHelper" do
          assert_match %r(^\s*extend Shaf::UriHelper$), output["app/serializers/blog.rb"]
        end
      end

      describe "serializer with attributes" do
        let(:generator) do
          Factory.create(*%w(serializer blog user message))
        end

        it "specifies attributes" do
          assert_match %r(^\s*attribute :user), output["app/serializers/blog.rb"]
          assert_match %r(^\s*attribute :message), output["app/serializers/blog.rb"]
        end
      end
    end
  end
end
