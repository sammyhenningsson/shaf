require 'test_helper'

module Shaf
  module Generator
    describe Controller do
      let(:output) { {} }

      let(:write_stub) do
        lambda do |file, content|
          output[file] = content
        end
      end

      before do
        File.stub :write, write_stub do
          Dir.stub :exist?, true do
            generator.stub :add_link_to_root, nil do
              Mutable.suppress_output { generator.call }
            end
          end
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
