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
            Mutable.suppress_output { generator.call }
          end
        end
      end

      describe "empty controller" do
        let(:file) { "app/controllers/blog.rb" }
        let(:generator) do
          Factory.create(*%w(controller blog))
        end

        it "creates file in app/controllers" do
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