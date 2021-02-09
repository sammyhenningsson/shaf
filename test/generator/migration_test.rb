require 'test_helper'
require 'generator/stubbed_output'

module Shaf
  module Generator
    module Migration
      describe Generator do
        extend StubbedOutput

        let(:subject) do
          DB.stub :table_exists?, true do
            generator.call
          end
        end

        describe "create table" do
          let(:table_name) { "blogs" }
          let(:generator) do
            Generator.new(
              'create',
              'table',
              'blogs',
              'message:string',
              'word_count:integer',
              'user_id:foreign_key,users',
              'message:index'
            )
          end

          it "creates file in db/migrations" do
            assert output.keys.first.start_with? "db/migrations"
          end

          it "adds timestamp to filename" do
            file = File.basename output.keys.first
            assert_match %r(\A\d{14}_), file
          end

          it "names the migration file correctly" do
            file = File.basename output.keys.first
            assert_match %r(_create_#{table_name}_table\.rb\Z), file
          end

          it "has the right content" do
            assert_equal 1, output.size
            content = output.values.first
            assert_match %r(create_table\(:#{table_name}\) do$), content
            assert_match %r(primary_key :id$), content
            assert_match %r(String :message$), content
            assert_match %r(Integer :word_count$), content
            assert_match %r(foreign_key :user_id, :users), content
            assert_match %r(index :message, unique: true), content
          end
        end

        describe "add column" do
          let(:table_name) { "blogs" }
          let(:generator) do
            Generator.new(*%w(add column blogs comment:string))
          end

          it "names the migration file correctly" do
            file = File.basename output.keys.first
            assert_match %r(_add_comment_to_#{table_name}\.rb\Z), file
          end

          it "has the right content" do
            assert_equal 1, output.size
            content = output.values.first
            assert_match %r(alter_table\(:#{table_name}\) do$), content
            assert_match %r(add_column :comment, String), content
          end
        end

        describe "add a foreign_key" do
          let(:table_name) { "blogs" }
          let(:generator) do
            Generator.new(*%w(add column blogs user_id:foreign_key,users))
          end

          it "names the migration file correctly" do
            file = File.basename output.keys.first
            assert_match %r(_add_user_id_to_#{table_name}\.rb\Z), file
          end

          it "has the right content" do
            assert_equal 1, output.size
            content = output.values.first
            assert_match %r(alter_table\(:#{table_name}\) do$), content
            assert_match %r(add_foreign_key :user_id, :users), content
          end
        end

        describe "add an index" do
          let(:table_name) { "blogs" }
          let(:generator) do
            Generator.new(*%w(add index blogs user_id))
          end

          it "names the migration file correctly" do
            file = File.basename output.keys.first
            assert_match %r(_add_user_id_index_to_#{table_name}\.rb\Z), file
          end

          it "has the right content" do
            assert_equal 1, output.size
            content = output.values.first
            assert_match %r(alter_table\(:#{table_name}\) do$), content
            assert_match %r(add_index :user_id), content
          end
        end

        describe "drop column" do
          let(:table_name) { "blogs" }
          let(:generator) do
            Generator.new(*%w(drop column blogs comment))
          end

          it "names the migration file correctly" do
            file = File.basename output.keys.first
            assert_match %r(_drop_comment_from_#{table_name}\.rb\Z), file
          end

          it "has the right content" do
            assert_equal 1, output.size
            content = output.values.first
            assert_match %r(alter_table\(:#{table_name}\) do$), content
            assert_match %r(drop_column :comment), content
          end
        end

        describe "rename column" do
          let(:table_name) { "blogs" }
          let(:generator) do
            Generator.new(*%w(rename column blogs comment tweet))
          end

          it "names the migration file correctly" do
            file = File.basename output.keys.first
            assert_match %r(_rename_#{table_name}_comment_to_tweet\.rb\Z), file
          end

          it "has the right content" do
            assert_equal 1, output.size
            content = output.values.first
            assert_match %r(alter_table\(:#{table_name}\) do$), content
            assert_match %r(rename_column :comment, :tweet), content
          end
        end
      end
    end
  end
end
