require 'test_helper'
require 'ostruct'

module Shaf
  describe ResourceUris do

    let(:resrc) { OpenStruct.new(id: 5) }

    def assert_method_registered(m)
      assert Shaf::UriHelper.respond_to? m
      assert Shaf::UriHelper.method_defined? m
    end

    describe "uri methods" do

      CreateUriMethods.new(:foo).call

      it "adds foos_uri method to Shaf::UriHelper" do
        assert_method_registered :foos_uri
        assert_equal '/foos', Shaf::UriHelper.foos_uri
        assert_equal '/foos', Shaf::UriHelper.foos_uri_template
        assert_equal '/foos?bar=5&baz=fem', Shaf::UriHelper.foos_uri(bar: 5, baz: "fem")
      end

      it "adds foo_uri method to Shaf::UriHelper" do
        assert_method_registered :foo_uri
        assert_equal '/foos/5', Shaf::UriHelper.foo_uri(resrc)
        assert_equal '/foos/:id', Shaf::UriHelper.foo_uri_template
        assert_equal '/foos/5?bar=5&baz=fem', Shaf::UriHelper.foo_uri(resrc, bar: 5, baz: "fem")
      end

      it "adds new_foo_uri method to Shaf::UriHelper" do
        assert_method_registered :new_foo_uri
        assert_equal '/foos/form', Shaf::UriHelper.new_foo_uri
        assert_equal '/foos/form', Shaf::UriHelper.new_foo_uri_template
        assert_equal '/foos/form?bar=5&baz=fem', Shaf::UriHelper.new_foo_uri(bar: 5, baz: "fem")
      end

      it "adds edit_foo_uri method to Shaf::UriHelper" do
        assert_method_registered :edit_foo_uri
        assert_equal '/foos/5/edit', Shaf::UriHelper.edit_foo_uri(resrc)
        assert_equal '/foos/:id/edit', Shaf::UriHelper.edit_foo_uri_template
        assert_equal '/foos/5/edit?bar=5&baz=fem', Shaf::UriHelper.edit_foo_uri(resrc, bar: 5, baz: "fem")
      end
    end

    describe "uri methods with a prefix" do

      CreateUriMethods.new(:bar, base: '/api').call

      it "adds prefix to return value of bars_uri method" do
        assert_method_registered :bars_uri
        assert_equal '/api/bars', Shaf::UriHelper.bars_uri
        assert_equal '/api/bars', Shaf::UriHelper.bars_uri_template
        assert_equal '/api/bars?bar=5&baz=fem', Shaf::UriHelper.bars_uri(bar: 5, baz: "fem")
      end

      it "adds prefix to return value of bar_uri method" do
        assert_method_registered :bar_uri
        assert_equal '/api/bars/5', Shaf::UriHelper.bar_uri(resrc)
        assert_equal '/api/bars/:id', Shaf::UriHelper.bar_uri_template
        assert_equal '/api/bars/5?bar=5&baz=fem', Shaf::UriHelper.bar_uri(resrc, bar: 5, baz: "fem")
      end

      it "adds prefix to return value of new_bar_uri method" do
        assert_method_registered :new_bar_uri
        assert_equal '/api/bars/form', Shaf::UriHelper.new_bar_uri
        assert_equal '/api/bars/form', Shaf::UriHelper.new_bar_uri_template
        assert_equal '/api/bars/form?bar=5&baz=fem', Shaf::UriHelper.new_bar_uri(bar: 5, baz: "fem")
      end

      it "adds prefix to return value of edit_bar_uri method" do
        assert_method_registered :edit_bar_uri
        assert_equal '/api/bars/5/edit', Shaf::UriHelper.edit_bar_uri(resrc)
        assert_equal '/api/bars/:id/edit', Shaf::UriHelper.edit_bar_uri_template
        assert_equal '/api/bars/5/edit?bar=5&baz=fem', Shaf::UriHelper.edit_bar_uri(resrc, bar: 5, baz: "fem")
      end
    end

    describe "nested resource uris" do

      CreateUriMethods.new(:comment, base: '/users/:foo').call

      it "adds a nested comments_uri method" do
        assert_method_registered :comments_uri
        assert_equal '/users/3/comments', Shaf::UriHelper.comments_uri(3)
        assert_equal '/users/4/comments', Shaf::UriHelper.comments_uri(OpenStruct.new(foo: 4))
        assert_equal '/users/:foo/comments', Shaf::UriHelper.comments_uri_template
        assert_equal '/users/3/comments?bar=5&baz=fem', Shaf::UriHelper.comments_uri(3, bar: 5, baz: "fem")
      end

      it "adds a nested comment_uri method" do
        assert_method_registered :comment_uri
        assert_equal '/users/3/comments/5', Shaf::UriHelper.comment_uri(3, resrc)
        assert_equal '/users/4/comments/6', Shaf::UriHelper.comment_uri(OpenStruct.new(foo: 4), 6)
        assert_equal '/users/:foo/comments/:id', Shaf::UriHelper.comment_uri_template
        assert_equal '/users/3/comments/5?bar=5&baz=fem', Shaf::UriHelper.comment_uri(3, resrc, bar: 5, baz: "fem")
      end

      it "adds a nested new_comment_uri method" do
        assert_method_registered :new_comment_uri
        assert_equal '/users/3/comments/form', Shaf::UriHelper.new_comment_uri(3)
        assert_equal '/users/4/comments/form', Shaf::UriHelper.new_comment_uri(OpenStruct.new(foo: 4))
        assert_equal '/users/:foo/comments/form', Shaf::UriHelper.new_comment_uri_template
        assert_equal '/users/3/comments/form?bar=5&baz=fem', Shaf::UriHelper.new_comment_uri(3, bar: 5, baz: "fem")
      end

      it "adds a nested edit_comment_uri method" do
        assert_method_registered :edit_comment_uri
        assert_equal '/users/3/comments/5/edit', Shaf::UriHelper.edit_comment_uri(3, resrc)
        assert_equal '/users/4/comments/6/edit', Shaf::UriHelper.edit_comment_uri(OpenStruct.new(foo: 4), 6)
        assert_equal '/users/:foo/comments/:id/edit', Shaf::UriHelper.edit_comment_uri_template
        assert_equal '/users/3/comments/5/edit?bar=5&baz=fem', Shaf::UriHelper.edit_comment_uri(3, resrc, bar: 5, baz: "fem")
      end
    end

    describe "uri methods with specified plural name" do

      CreateUriMethods.new(:baz, plural_name: 'baz').call

      it "adds baz_uri method to Shaf::UriHelper" do
        assert_method_registered :baz_uri
        assert_equal '/baz', Shaf::UriHelper.baz_uri
        assert_equal '/baz', Shaf::UriHelper.baz_uri_template(true)
        assert_equal '/baz?bar=5&baz=fem', Shaf::UriHelper.baz_uri(bar: 5, baz: "fem")
      end

      it "adds baz_uri(id) method to Shaf::UriHelper" do
        assert_method_registered :baz_uri
        assert_equal '/baz/5', Shaf::UriHelper.baz_uri(resrc)
        assert_equal '/baz/:id', Shaf::UriHelper.baz_uri_template
        assert_equal '/baz/5?bar=5&baz=fem', Shaf::UriHelper.baz_uri(resrc, bar: 5, baz: "fem")
      end

      it "adds new_baz_uri method to Shaf::UriHelper" do
        assert_method_registered :baz_uri
        assert_equal '/baz/form', Shaf::UriHelper.new_baz_uri
        assert_equal '/baz/form', Shaf::UriHelper.new_baz_uri_template
        assert_equal '/baz/form?bar=5&baz=fem', Shaf::UriHelper.new_baz_uri(bar: 5, baz: "fem")
      end

      it "adds edit_baz_uri method to Shaf::UriHelper" do
        assert_method_registered :baz_uri
        assert_equal '/baz/5/edit', Shaf::UriHelper.edit_baz_uri(resrc)
        assert_equal '/baz/:id/edit', Shaf::UriHelper.edit_baz_uri_template
        assert_equal '/baz/5/edit?bar=5&baz=fem', Shaf::UriHelper.edit_baz_uri(resrc, bar: 5, baz: "fem")
      end
    end

    describe MethodBuilder do

      let(:builder) { MethodBuilder.new("hide_book", "/my/books/:id/archive") }

      it "#method_name" do
        assert_equal "hide_book_uri", builder.send(:method_name)
      end

      it "#template_method_name" do
        assert_equal "hide_book_uri_template", builder.send(:template_method_name)
      end

      it "#signature" do
        assert_equal "hide_book_uri(arg0, **query)", builder.send(:signature)
      end

      it "#as_string" do
        method_string = builder.send(:method_string)

        a_clazz = Class.new
        an_instance = a_clazz.new
        an_instance.instance_eval method_string

        assert an_instance.respond_to? :hide_book_uri

        book = OpenStruct.new(id: 5)
        assert_equal "/my/books/6/archive", an_instance.hide_book_uri(6)
        assert_equal "/my/books/5/archive", an_instance.hide_book_uri(book)
        assert_equal(
          "/my/books/5/archive?bar=5&baz=fem",
          an_instance.hide_book_uri(book, bar: 5, baz: "fem")
        )
      end
    end
  end
end
