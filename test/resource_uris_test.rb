require 'test_helper'
require 'ostruct'

module Shaf
  describe ResourceUris do

    before do
      @resrc = OpenStruct.new(id: 5)
    end

    def assert_method_registered(m)
      assert Shaf::UriHelper.respond_to? m
      assert Shaf::UriHelper.method_defined? m
    end

    describe "uri methods" do

      CreateUriMethods.new(:foo).call

      it "adds foos_uri method to Shaf::UriHelper" do
        assert_method_registered :foos_uri
        assert_equal '/foos', Shaf::UriHelper.foos_uri
      end

      it "adds foo_uri method to Shaf::UriHelper" do
        assert_method_registered :foo_uri
        assert_equal '/foos/5', Shaf::UriHelper.foo_uri(@resrc)
      end

      it "adds new_foo_uri method to Shaf::UriHelper" do
        assert_method_registered :new_foo_uri
        assert_equal '/foos/form', Shaf::UriHelper.new_foo_uri
      end

      it "adds edit_foo_uri method to Shaf::UriHelper" do
        assert_method_registered :edit_foo_uri
        assert_equal '/foos/5/edit', Shaf::UriHelper.edit_foo_uri(@resrc)
      end
    end

    describe "uri methods with a prefix" do

      CreateUriMethods.new(:bar, base: '/api').call

      it "adds prefix to return value of bars_uri method" do
        assert_method_registered :bars_uri
        assert_equal '/api/bars', Shaf::UriHelper.bars_uri
      end

      it "adds prefix to return value of bar_uri method" do
        assert_method_registered :bar_uri
        assert_equal '/api/bars/5', Shaf::UriHelper.bar_uri(@resrc)
      end

      it "adds prefix to return value of new_bar_uri method" do
        assert_method_registered :new_bar_uri
        assert_equal '/api/bars/form', Shaf::UriHelper.new_bar_uri
      end

      it "adds prefix to return value of edit_bar_uri method" do
        assert_method_registered :edit_bar_uri
        assert_equal '/api/bars/5/edit', Shaf::UriHelper.edit_bar_uri(@resrc)
      end
    end

    describe "uri methods with specified plural name" do

      CreateUriMethods.new(:baz, plural_name: 'baz').call

      it "adds baz_uri method to Shaf::UriHelper" do
        assert_method_registered :baz_uri
        assert_equal '/baz', Shaf::UriHelper.baz_uri
      end

      it "adds baz_uri(id) method to Shaf::UriHelper" do
        assert_method_registered :baz_uri
        assert_equal '/baz/5', Shaf::UriHelper.baz_uri(@resrc)
      end

      it "adds new_baz_uri method to Shaf::UriHelper" do
        assert_method_registered :baz_uri
        assert_equal '/baz/form', Shaf::UriHelper.new_baz_uri
      end

      it "adds edit_baz_uri method to Shaf::UriHelper" do
        assert_method_registered :baz_uri
        assert_equal '/baz/5/edit', Shaf::UriHelper.edit_baz_uri(@resrc)
      end

    end

    describe MethodBuilder do

      it "::method_name" do
        assert_equal "/foo_uri", MethodBuilder::method_name("/foo")
      end

      it "::signature" do
        assert_equal "some_method_uri(id)", MethodBuilder::signature(:some_method, "/some_resource/:id/edit")
      end

      it "::as_string" do
        method_string = MethodBuilder.as_string("book", "/books/:id")

        a_clazz = Class.new
        an_instance = a_clazz.new
        an_instance.instance_eval method_string

        assert an_instance.respond_to? :book_uri

        book = OpenStruct.new(id: 5)
        assert_equal "/books/6", an_instance.book_uri(6)
        assert_equal "/books/5", an_instance.book_uri(book)
      end
    end
  end
end
