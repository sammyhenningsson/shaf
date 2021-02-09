require 'test_helper'
require 'generator/stubbed_output'

module Shaf
  module Generator
    describe Controller do
      extend StubbedOutput

      let(:subject) do
        generator.stub :add_link_to_root, nil do
          generator.call
        end
      end

      describe "empty controller" do
        let(:file) { "api/controllers/blogs_controller.rb" }
        let(:generator) do
          Factory.create(*%w(controller blog))
        end

        it "creates file in api/controllers" do
          assert_includes output.keys, file
        end

        it "declares the blogs controller class" do
          assert_match %r(^class BlogsController < BaseController$), output[file]
        end

        it "registers resource uris" do
          assert_match %r(^\s*resource_uris_for :blog$), output[file]
        end
      end
    end
  end
end
