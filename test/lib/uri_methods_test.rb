require 'test_helper'
require 'ostruct'

module Lib
  module UriMethods
    class UriMethodsTest < MiniTest::Test
      def setup
        @resrc = OpenStruct.new(id: 5)
        return if defined? @@run_once
        CreateUriMethods.new(:foo).call
        @@run_once = true
      end

      def assert_method_registered(m)
        assert UriHelper.respond_to? m
        assert UriHelper.method_defined? m
      end

      def test_resources_uri_method
        assert_method_registered :foos_uri
        assert_equal '/foos', UriHelper.foos_uri
      end

      def test_resource_uri_method
        assert_method_registered :foo_uri
        assert_equal '/foos/5', UriHelper.foo_uri(@resrc)
      end

      def test_new_resource_uri_method
        assert_method_registered :new_foo_uri
        assert_equal '/foos/form', UriHelper.new_foo_uri
      end

      def test_edit_resource_uri_method
        assert_method_registered :edit_foo_uri
        assert_equal '/foos/5/edit', UriHelper.edit_foo_uri(@resrc)
      end

    end

    class BaseUriTest < MiniTest::Test
      def setup
        @resrc = OpenStruct.new(id: 5)
        return if defined? @@run_once
        CreateUriMethods.new(:bar, base: '/api').call
        @@run_once = true
      end

      def assert_method_registered(m)
        assert UriHelper.respond_to? m
        assert UriHelper.method_defined? m
      end

      def test_resources_uri_method
        assert_method_registered :bars_uri
        assert_equal '/api/bars', UriHelper.bars_uri
      end

      def test_resource_uri_method
        assert_method_registered :bar_uri
        assert_equal '/api/bars/5', UriHelper.bar_uri(@resrc)
      end

      def test_new_resource_uri_method
        assert_method_registered :new_bar_uri
        assert_equal '/api/bars/form', UriHelper.new_bar_uri
      end

      def test_edit_resource_uri_method
        assert_method_registered :edit_bar_uri
        assert_equal '/api/bars/5/edit', UriHelper.edit_bar_uri(@resrc)
      end

    end

    class PluralNameTest < MiniTest::Test
      def setup
        @resrc = OpenStruct.new(id: 5)
        return if defined? @@run_once
        CreateUriMethods.new(:baz, plural_name: 'baz').call
        @@run_once = true
      end

      def assert_method_registered(m)
        assert UriHelper.respond_to? m
        assert UriHelper.method_defined? m
      end

      def test_resources_uri_method
        assert_method_registered :baz_uri
        assert_equal '/baz', UriHelper.baz_uri
      end

      def test_resource_uri_method
        assert_method_registered :baz_uri
        assert_equal '/baz/5', UriHelper.baz_uri(@resrc)
      end

      def test_new_resource_uri_method
        assert_method_registered :baz_uri
        assert_equal '/baz/form', UriHelper.new_baz_uri
      end

      def test_edit_resource_uri_method
        assert_method_registered :baz_uri
        assert_equal '/baz/5/edit', UriHelper.edit_baz_uri(@resrc)
      end

    end

    class MethodBuilderTest < MiniTest::Test

      def test_method_name
        assert_equal "/foo_uri", MethodBuilder::method_name("/foo")
      end

      def test_signature
        assert_equal "some_method_uri(id)", MethodBuilder::signature(:some_method, "/some_resource/:id/edit")
      end

      def test_as_string
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

