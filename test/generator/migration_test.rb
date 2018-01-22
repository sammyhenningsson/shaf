require 'test_helper'

module Shaf
  module Generator
    module Migration
      describe Generator do
        let(:output_file) { "" }
        let(:output) { "" }

        let(:write_stub) do
          lambda do |file, content|
            output_file << file
            output << content
          end
        end

        before do
          File.stub :write, write_stub do
            Dir.stub :exist?, true do
              Mutable.suppress_output { generator.call }
            end
          end
        end

        describe "create table" do
          let(:table_name) { "blogs" }
          let(:generator) do
            Generator.new(*%w(create table blogs message:string user_id:integer))
          end

          it "creates file in db/migrations" do
            assert output_file.start_with? "db/migrations"
          end

          it "adds timestamp to filename" do
            file = File.basename output_file
            assert_match /\A\d{14}_/, file
          end

          it "names the migration file correctly" do
            file = File.basename output_file
            assert_match /_create_#{table_name}_table\.rb\Z/, file
          end

          it "has the right content" do
            assert_match /create_table\(:#{table_name}\) do$/, output
            assert_match /primary_key :id$/, output
            assert_match /String :message$/, output
            assert_match /Integer :user_id$/, output
          end
        end

        describe "add column" do
          let(:table_name) { "blogs" }
          let(:generator) do
            Generator.new(*%w(add column blogs comment:string))
          end

          it "names the migration file correctly" do
            file = File.basename output_file
            assert_match /_add_comment_to_#{table_name}\.rb\Z/, file
          end

          it "has the right content" do
            assert_match /alter_table\(:#{table_name}\) do$/, output
            assert_match /add_column :comment, String/, output
          end
        end

      end
    end
  end
end
