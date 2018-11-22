require 'test_helper'
require 'ostruct'

module Shaf
  describe ResourceUris do

    let(:base_uri) { UriHelper.base_uri }
    let(:resrc) { OpenStruct.new(id: 5) }

    def assert_methods_registered(*methods)
      methods.each do |m|
        assert Shaf::UriHelper.respond_to? m
        assert Shaf::UriHelper.method_defined? m
      end
    end

    after do
      UriHelperMethods.remove_all
    end

    describe "uri methods" do
      before do
        CreateUriMethods.new(:foo).call
      end

      it "adds foos_uri method to Shaf::UriHelper" do
        assert_methods_registered :foos_uri, :foos_path
        assert_equal "#{base_uri}/foos", Shaf::UriHelper.foos_uri
        assert_equal "/foos", Shaf::UriHelper.foos_path
        assert_equal '/foos', Shaf::UriHelper.foos_uri_template
        assert_equal "#{base_uri}/foos?bar=5&baz=fem", Shaf::UriHelper.foos_uri(bar: 5, baz: "fem")
      end

      it "adds foo_uri method to Shaf::UriHelper" do
        assert_methods_registered :foo_uri, :foo_path
        assert_equal "#{base_uri}/foos/5", Shaf::UriHelper.foo_uri(resrc)
        assert_equal "/foos/5", Shaf::UriHelper.foo_path(resrc)
        assert_equal '/foos/:id', Shaf::UriHelper.foo_uri_template
        assert_equal "#{base_uri}/foos/5?bar=5&baz=fem", Shaf::UriHelper.foo_uri(resrc, bar: 5, baz: "fem")
      end

      it "adds new_foo_uri method to Shaf::UriHelper" do
        assert_methods_registered :new_foo_uri, :new_foo_path
        assert_equal "#{base_uri}/foo/form", Shaf::UriHelper.new_foo_uri
        assert_equal "/foo/form", Shaf::UriHelper.new_foo_path
        assert_equal '/foo/form', Shaf::UriHelper.new_foo_uri_template
        assert_equal "#{base_uri}/foo/form?bar=5&baz=fem", Shaf::UriHelper.new_foo_uri(bar: 5, baz: "fem")
      end

      it "adds edit_foo_uri method to Shaf::UriHelper" do
        assert_methods_registered :edit_foo_uri, :edit_foo_path
        assert_equal "#{base_uri}/foos/5/edit", Shaf::UriHelper.edit_foo_uri(resrc)
        assert_equal "/foos/5/edit", Shaf::UriHelper.edit_foo_path(resrc)
        assert_equal '/foos/:id/edit', Shaf::UriHelper.edit_foo_uri_template
        assert_equal "#{base_uri}/foos/5/edit?bar=5&baz=fem", Shaf::UriHelper.edit_foo_uri(resrc, bar: 5, baz: "fem")
      end

      it "adds path matcher methods" do
        assert_methods_registered *%i[foos_path? foo_path? new_foo_path? edit_foo_path?]

        assert Shaf::UriHelper.foos_path? '/foos'
        assert Shaf::UriHelper.foo_path? '/foos/5'
        assert Shaf::UriHelper.new_foo_path? '/foo/form'
        assert Shaf::UriHelper.edit_foo_path? '/foos/5/edit'

        refute Shaf::UriHelper.foos_path? '/nested/foos'
        refute Shaf::UriHelper.foos_path? '/foos/5'
        refute Shaf::UriHelper.new_foo_path? '/foos/5'
        refute Shaf::UriHelper.foo_path? '/foo/form'
      end
    end

    describe "uri methods with a prefix" do

      before do
        CreateUriMethods.new(:bar, base: '/api').call
      end

      it "adds prefix to return value of bars_uri method" do
        assert_methods_registered :bars_uri, :bars_path
        assert_equal "#{base_uri}/api/bars", Shaf::UriHelper.bars_uri
        assert_equal "/api/bars", Shaf::UriHelper.bars_path
        assert_equal '/api/bars', Shaf::UriHelper.bars_uri_template
        assert_equal "#{base_uri}/api/bars?bar=5&baz=fem", Shaf::UriHelper.bars_uri(bar: 5, baz: "fem")
      end

      it "adds prefix to return value of bar_uri method" do
        assert_methods_registered :bar_uri, :bar_path
        assert_equal "#{base_uri}/api/bars/5", Shaf::UriHelper.bar_uri(resrc)
        assert_equal "/api/bars/5", Shaf::UriHelper.bar_path(resrc)
        assert_equal '/api/bars/:id', Shaf::UriHelper.bar_uri_template
        assert_equal "#{base_uri}/api/bars/5?bar=5&baz=fem", Shaf::UriHelper.bar_uri(resrc, bar: 5, baz: "fem")
      end

      it "adds prefix to return value of new_bar_uri method" do
        assert_methods_registered :new_bar_uri, :new_bar_path
        assert_equal "#{base_uri}/api/bar/form", Shaf::UriHelper.new_bar_uri
        assert_equal "/api/bar/form", Shaf::UriHelper.new_bar_path
        assert_equal '/api/bar/form', Shaf::UriHelper.new_bar_uri_template
        assert_equal "#{base_uri}/api/bar/form?bar=5&baz=fem", Shaf::UriHelper.new_bar_uri(bar: 5, baz: "fem")
      end

      it "adds prefix to return value of edit_bar_uri method" do
        assert_methods_registered :edit_bar_uri, :edit_bar_path
        assert_equal "#{base_uri}/api/bars/5/edit", Shaf::UriHelper.edit_bar_uri(resrc)
        assert_equal "/api/bars/5/edit", Shaf::UriHelper.edit_bar_path(resrc)
        assert_equal '/api/bars/:id/edit', Shaf::UriHelper.edit_bar_uri_template
        assert_equal "#{base_uri}/api/bars/5/edit?bar=5&baz=fem", Shaf::UriHelper.edit_bar_uri(resrc, bar: 5, baz: "fem")
      end
    end

    describe "nested resource uris" do

      before do
        CreateUriMethods.new(:comment, base: '/users/:foo').call
      end

      it "adds a nested comments_uri method" do
        assert_methods_registered :comments_uri
        assert_equal "#{base_uri}/users/3/comments", Shaf::UriHelper.comments_uri(3)
        assert_equal "#{base_uri}/users/4/comments", Shaf::UriHelper.comments_uri(OpenStruct.new(foo: 4))
        assert_equal "/users/3/comments", Shaf::UriHelper.comments_path(3)
        assert_equal "/users/4/comments", Shaf::UriHelper.comments_path(OpenStruct.new(foo: 4))
        assert_equal '/users/:foo/comments', Shaf::UriHelper.comments_uri_template
        assert_equal "#{base_uri}/users/3/comments?bar=5&baz=fem", Shaf::UriHelper.comments_uri(3, bar: 5, baz: "fem")
      end

      it "adds a nested comment_uri method" do
        assert_methods_registered :comment_uri
        assert_equal "#{base_uri}/users/3/comments/5", Shaf::UriHelper.comment_uri(3, resrc)
        assert_equal "#{base_uri}/users/4/comments/6", Shaf::UriHelper.comment_uri(OpenStruct.new(foo: 4), 6)
        assert_equal "/users/3/comments/5", Shaf::UriHelper.comment_path(3, resrc)
        assert_equal "/users/4/comments/6", Shaf::UriHelper.comment_path(OpenStruct.new(foo: 4), 6)
        assert_equal '/users/:foo/comments/:id', Shaf::UriHelper.comment_uri_template
        assert_equal "#{base_uri}/users/3/comments/5?bar=5&baz=fem", Shaf::UriHelper.comment_uri(3, resrc, bar: 5, baz: "fem")
      end

      it "adds a nested new_comment_uri method" do
        assert_methods_registered :new_comment_uri
        assert_equal "#{base_uri}/users/3/comment/form", Shaf::UriHelper.new_comment_uri(3)
        assert_equal "#{base_uri}/users/4/comment/form", Shaf::UriHelper.new_comment_uri(OpenStruct.new(foo: 4))
        assert_equal "/users/3/comment/form", Shaf::UriHelper.new_comment_path(3)
        assert_equal "/users/4/comment/form", Shaf::UriHelper.new_comment_path(OpenStruct.new(foo: 4))
        assert_equal '/users/:foo/comment/form', Shaf::UriHelper.new_comment_uri_template
        assert_equal "#{base_uri}/users/3/comment/form?bar=5&baz=fem", Shaf::UriHelper.new_comment_uri(3, bar: 5, baz: "fem")
      end

      it "adds a nested edit_comment_uri method" do
        assert_methods_registered :edit_comment_uri
        assert_equal "#{base_uri}/users/3/comments/5/edit", Shaf::UriHelper.edit_comment_uri(3, resrc)
        assert_equal "#{base_uri}/users/4/comments/6/edit", Shaf::UriHelper.edit_comment_uri(OpenStruct.new(foo: 4), 6)
        assert_equal "/users/3/comments/5/edit", Shaf::UriHelper.edit_comment_path(3, resrc)
        assert_equal "/users/4/comments/6/edit", Shaf::UriHelper.edit_comment_path(OpenStruct.new(foo: 4), 6)
        assert_equal '/users/:foo/comments/:id/edit', Shaf::UriHelper.edit_comment_uri_template
        assert_equal "#{base_uri}/users/3/comments/5/edit?bar=5&baz=fem", Shaf::UriHelper.edit_comment_uri(3, resrc, bar: 5, baz: "fem")
      end
    end

    describe "uri methods with specified plural name" do
      before do
        CreateUriMethods.new(:baz, plural_name: 'baz').call
      end

      it "adds baz_uri method to Shaf::UriHelper" do
        assert_methods_registered :baz_uri, :baz_path
        assert_equal "#{base_uri}/baz", Shaf::UriHelper.baz_uri
        assert_equal "/baz", Shaf::UriHelper.baz_path
        assert_equal '/baz', Shaf::UriHelper.baz_uri_template(true)
        assert_equal "#{base_uri}/baz?bar=5&baz=fem", Shaf::UriHelper.baz_uri(bar: 5, baz: "fem")
      end

      it "adds baz_uri(id) method to Shaf::UriHelper" do
        assert_methods_registered :baz_uri, :baz_path
        assert_equal "#{base_uri}/baz/5", Shaf::UriHelper.baz_uri(resrc)
        assert_equal "/baz/5", Shaf::UriHelper.baz_path(resrc)
        assert_equal '/baz/:id', Shaf::UriHelper.baz_uri_template
        assert_equal "#{base_uri}/baz/5?bar=5&baz=fem", Shaf::UriHelper.baz_uri(resrc, bar: 5, baz: "fem")
      end

      it "adds new_baz_uri method to Shaf::UriHelper" do
        assert_methods_registered :baz_uri, :baz_path
        assert_equal "#{base_uri}/baz/form", Shaf::UriHelper.new_baz_uri
        assert_equal "/baz/form", Shaf::UriHelper.new_baz_path
        assert_equal '/baz/form', Shaf::UriHelper.new_baz_uri_template
        assert_equal "#{base_uri}/baz/form?bar=5&baz=fem", Shaf::UriHelper.new_baz_uri(bar: 5, baz: "fem")
      end

      it "adds edit_baz_uri method to Shaf::UriHelper" do
        assert_methods_registered :baz_uri, :baz_path
        assert_equal "#{base_uri}/baz/5/edit", Shaf::UriHelper.edit_baz_uri(resrc)
        assert_equal "/baz/5/edit", Shaf::UriHelper.edit_baz_path(resrc)
        assert_equal '/baz/:id/edit', Shaf::UriHelper.edit_baz_uri_template
        assert_equal "#{base_uri}/baz/5/edit?bar=5&baz=fem", Shaf::UriHelper.edit_baz_uri(resrc, bar: 5, baz: "fem")
      end

      it "adds path matcher methods" do
        assert_methods_registered *%i[baz_path? new_baz_path? edit_baz_path?]

        assert Shaf::UriHelper.baz_path? '/baz', collection: true
        assert Shaf::UriHelper.baz_path? '/baz/5'
        assert Shaf::UriHelper.new_baz_path? '/baz/form'
        assert Shaf::UriHelper.edit_baz_path? '/baz/5/edit'

        refute Shaf::UriHelper.baz_path? '/nested/baz', collection: true
        refute Shaf::UriHelper.baz_path? '/nested/bazs', collection: true
        refute Shaf::UriHelper.baz_path? '/baz/5', collection: true
        refute Shaf::UriHelper.baz_path? '/baz', collection: false
      end
    end

    describe MethodBuilder do
      let(:builder) { MethodBuilder.new("hide_book", "/my/books/:id/archive") }

      it "#uri_method_name" do
        assert_equal "hide_book_uri", builder.send(:uri_method_name)
      end

      it "#path_method_name" do
        assert_equal "hide_book_path", builder.send(:path_method_name)
      end

      it "#template_method_name" do
        assert_equal "hide_book_uri_template", builder.send(:template_method_name)
      end

      it "#uri_signature" do
        assert_equal "hide_book_uri(arg0, **query)", builder.send(:uri_signature)
      end

      it "#path_signature" do
        assert_equal "hide_book_path(arg0, **query)", builder.send(:path_signature)
      end

      it "#as_string" do
        uri_method_string = builder.send(:uri_method_string)

        a_clazz = Class.new
        an_instance = a_clazz.new
        an_instance.instance_eval uri_method_string

        assert an_instance.respond_to? :hide_book_uri

        book = OpenStruct.new(id: 5)
        assert_equal "#{base_uri}/my/books/6/archive", an_instance.hide_book_uri(6)
        assert_equal "#{base_uri}/my/books/5/archive", an_instance.hide_book_uri(book)
        assert_equal(
          "#{base_uri}/my/books/5/archive?bar=5&baz=fem",
          an_instance.hide_book_uri(book, bar: 5, baz: "fem")
        )
      end
    end
  end
end
