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
        assert_equal '/foos', Shaf::UriHelper.foos_path_template
        assert_equal "#{base_uri}/foos?bar=5&baz=fem", Shaf::UriHelper.foos_uri(bar: 5, baz: "fem")
      end

      it "adds foo_uri method to Shaf::UriHelper" do
        assert_methods_registered :foo_uri, :foo_path
        assert_equal "#{base_uri}/foos/5", Shaf::UriHelper.foo_uri(resrc)
        assert_equal "/foos/5", Shaf::UriHelper.foo_path(resrc)
        assert_equal '/foos/:id', Shaf::UriHelper.foo_path_template
        assert_equal "#{base_uri}/foos/5?bar=5&baz=fem", Shaf::UriHelper.foo_uri(resrc, bar: 5, baz: "fem")
      end

      it "adds new_foo_uri method to Shaf::UriHelper" do
        assert_methods_registered :new_foo_uri, :new_foo_path
        assert_equal "#{base_uri}/foo/form", Shaf::UriHelper.new_foo_uri
        assert_equal "/foo/form", Shaf::UriHelper.new_foo_path
        assert_equal '/foo/form', Shaf::UriHelper.new_foo_path_template
        assert_equal "#{base_uri}/foo/form?bar=5&baz=fem", Shaf::UriHelper.new_foo_uri(bar: 5, baz: "fem")
      end

      it "adds edit_foo_uri method to Shaf::UriHelper" do
        assert_methods_registered :edit_foo_uri, :edit_foo_path
        assert_equal "#{base_uri}/foos/5/edit", Shaf::UriHelper.edit_foo_uri(resrc)
        assert_equal "/foos/5/edit", Shaf::UriHelper.edit_foo_path(resrc)
        assert_equal '/foos/:id/edit', Shaf::UriHelper.edit_foo_path_template
        assert_equal "#{base_uri}/foos/5/edit?bar=5&baz=fem", Shaf::UriHelper.edit_foo_uri(resrc, bar: 5, baz: "fem")
      end

      it "is possible to specify a fragment id" do
        assert_equal "/foos#hello", Shaf::UriHelper.foos_path(fragment_id: 'hello')
        assert_equal "/foos/5#world", Shaf::UriHelper.foo_path(resrc, fragment_id: 'world')
        assert_equal "/foos?active=true#hello", Shaf::UriHelper.foos_path(active: true, fragment_id: 'hello')
      end

      it "adds path matcher methods" do
        assert_methods_registered(*%i[foos_path? foo_path? new_foo_path? edit_foo_path?])

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
        assert_equal '/api/bars', Shaf::UriHelper.bars_path_template
        assert_equal "#{base_uri}/api/bars?bar=5&baz=fem", Shaf::UriHelper.bars_uri(bar: 5, baz: "fem")
      end

      it "adds prefix to return value of bar_uri method" do
        assert_methods_registered :bar_uri, :bar_path
        assert_equal "#{base_uri}/api/bars/5", Shaf::UriHelper.bar_uri(resrc)
        assert_equal "/api/bars/5", Shaf::UriHelper.bar_path(resrc)
        assert_equal '/api/bars/:id', Shaf::UriHelper.bar_path_template
        assert_equal "#{base_uri}/api/bars/5?bar=5&baz=fem", Shaf::UriHelper.bar_uri(resrc, bar: 5, baz: "fem")
      end

      it "adds prefix to return value of new_bar_uri method" do
        assert_methods_registered :new_bar_uri, :new_bar_path
        assert_equal "#{base_uri}/api/bar/form", Shaf::UriHelper.new_bar_uri
        assert_equal "/api/bar/form", Shaf::UriHelper.new_bar_path
        assert_equal '/api/bar/form', Shaf::UriHelper.new_bar_path_template
        assert_equal "#{base_uri}/api/bar/form?bar=5&baz=fem", Shaf::UriHelper.new_bar_uri(bar: 5, baz: "fem")
      end

      it "adds prefix to return value of edit_bar_uri method" do
        assert_methods_registered :edit_bar_uri, :edit_bar_path
        assert_equal "#{base_uri}/api/bars/5/edit", Shaf::UriHelper.edit_bar_uri(resrc)
        assert_equal "/api/bars/5/edit", Shaf::UriHelper.edit_bar_path(resrc)
        assert_equal '/api/bars/:id/edit', Shaf::UriHelper.edit_bar_path_template
        assert_equal "#{base_uri}/api/bars/5/edit?bar=5&baz=fem", Shaf::UriHelper.edit_bar_uri(resrc, bar: 5, baz: "fem")
      end
    end

    describe "uri methods with a namespace" do

      before do
        CreateUriMethods.new(:bar, namespace: 'api').call
      end

      it "adds namespace to collection metods" do
        assert_methods_registered :api_bars_uri, :api_bars_path
        assert_equal "#{base_uri}/api/bars", Shaf::UriHelper.api_bars_uri
        assert_equal "/api/bars", Shaf::UriHelper.api_bars_path
        assert_equal '/api/bars', Shaf::UriHelper.api_bars_path_template
        assert_equal "#{base_uri}/api/bars?bar=5&baz=fem", Shaf::UriHelper.api_bars_uri(bar: 5, baz: "fem")
      end

      it "adds namespace to resource methods" do
        assert_methods_registered :api_bar_uri, :api_bar_path
        assert_equal "#{base_uri}/api/bars/5", Shaf::UriHelper.api_bar_uri(resrc)
        assert_equal "/api/bars/5", Shaf::UriHelper.api_bar_path(resrc)
        assert_equal '/api/bars/:id', Shaf::UriHelper.api_bar_path_template
        assert_equal "#{base_uri}/api/bars/5?bar=5&baz=fem", Shaf::UriHelper.api_bar_uri(resrc, bar: 5, baz: "fem")
      end

      it "adds namespace to new resource methods" do
        assert_methods_registered :new_api_bar_uri, :new_api_bar_path
        assert_equal "#{base_uri}/api/bar/form", Shaf::UriHelper.new_api_bar_uri
        assert_equal "/api/bar/form", Shaf::UriHelper.new_api_bar_path
        assert_equal '/api/bar/form', Shaf::UriHelper.new_api_bar_path_template
        assert_equal "#{base_uri}/api/bar/form?bar=5&baz=fem", Shaf::UriHelper.new_api_bar_uri(bar: 5, baz: "fem")
      end

      it "adds namespace to edit resource methods" do
        assert_methods_registered :edit_api_bar_uri, :edit_api_bar_path
        assert_equal "#{base_uri}/api/bars/5/edit", Shaf::UriHelper.edit_api_bar_uri(resrc)
        assert_equal "/api/bars/5/edit", Shaf::UriHelper.edit_api_bar_path(resrc)
        assert_equal '/api/bars/:id/edit', Shaf::UriHelper.edit_api_bar_path_template
        assert_equal "#{base_uri}/api/bars/5/edit?bar=5&baz=fem", Shaf::UriHelper.edit_api_bar_uri(resrc, bar: 5, baz: "fem")
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
        assert_equal '/users/:foo/comments', Shaf::UriHelper.comments_path_template
        assert_equal "#{base_uri}/users/3/comments?bar=5&baz=fem", Shaf::UriHelper.comments_uri(3, bar: 5, baz: "fem")
      end

      it "adds a nested comment_uri method" do
        assert_methods_registered :comment_uri
        assert_equal "#{base_uri}/users/3/comments/5", Shaf::UriHelper.comment_uri(3, resrc)
        assert_equal "#{base_uri}/users/4/comments/6", Shaf::UriHelper.comment_uri(OpenStruct.new(foo: 4), 6)
        assert_equal "/users/3/comments/5", Shaf::UriHelper.comment_path(3, resrc)
        assert_equal "/users/4/comments/6", Shaf::UriHelper.comment_path(OpenStruct.new(foo: 4), 6)
        assert_equal '/users/:foo/comments/:id', Shaf::UriHelper.comment_path_template
        assert_equal "#{base_uri}/users/3/comments/5?bar=5&baz=fem", Shaf::UriHelper.comment_uri(3, resrc, bar: 5, baz: "fem")
      end

      it "adds a nested new_comment_uri method" do
        assert_methods_registered :new_comment_uri
        assert_equal "#{base_uri}/users/3/comment/form", Shaf::UriHelper.new_comment_uri(3)
        assert_equal "#{base_uri}/users/4/comment/form", Shaf::UriHelper.new_comment_uri(OpenStruct.new(foo: 4))
        assert_equal "/users/3/comment/form", Shaf::UriHelper.new_comment_path(3)
        assert_equal "/users/4/comment/form", Shaf::UriHelper.new_comment_path(OpenStruct.new(foo: 4))
        assert_equal '/users/:foo/comment/form', Shaf::UriHelper.new_comment_path_template
        assert_equal "#{base_uri}/users/3/comment/form?bar=5&baz=fem", Shaf::UriHelper.new_comment_uri(3, bar: 5, baz: "fem")
      end

      it "adds a nested edit_comment_uri method" do
        assert_methods_registered :edit_comment_uri
        assert_equal "#{base_uri}/users/3/comments/5/edit", Shaf::UriHelper.edit_comment_uri(3, resrc)
        assert_equal "#{base_uri}/users/4/comments/6/edit", Shaf::UriHelper.edit_comment_uri(OpenStruct.new(foo: 4), 6)
        assert_equal "/users/3/comments/5/edit", Shaf::UriHelper.edit_comment_path(3, resrc)
        assert_equal "/users/4/comments/6/edit", Shaf::UriHelper.edit_comment_path(OpenStruct.new(foo: 4), 6)
        assert_equal '/users/:foo/comments/:id/edit', Shaf::UriHelper.edit_comment_path_template
        assert_equal "#{base_uri}/users/3/comments/5/edit?bar=5&baz=fem", Shaf::UriHelper.edit_comment_uri(3, resrc, bar: 5, baz: "fem")
      end
    end

    describe "uri methods with specified plural name" do
      before do
        CreateUriMethods.new(:baz, plural_name: 'baz').call
      end

      it "adds collection methods, baz_uri, to Shaf::UriHelper" do
        assert_methods_registered :baz_uri, :baz_path, :baz_collection_uri, :baz_collection_path
        assert_equal "#{base_uri}/baz", Shaf::UriHelper.baz_collection_uri
        assert_equal "/baz", Shaf::UriHelper.baz_collection_path
        assert_equal '/baz', Shaf::UriHelper.baz_collection_path_template
        assert_equal "#{base_uri}/baz?bar=5&baz=fem", Shaf::UriHelper.baz_collection_uri(bar: 5, baz: "fem")
      end

      it "adds resource methods, baz_uri(id), to Shaf::UriHelper" do
        assert_methods_registered :baz_uri, :baz_path
        assert_equal "#{base_uri}/baz/5", Shaf::UriHelper.baz_uri(resrc)
        assert_equal "/baz/5", Shaf::UriHelper.baz_path(resrc)
        assert_equal '/baz/:id', Shaf::UriHelper.baz_path_template
        assert_equal "#{base_uri}/baz/5?bar=5&baz=fem", Shaf::UriHelper.baz_uri(resrc, bar: 5, baz: "fem")
      end

      it "adds new_baz_uri method to Shaf::UriHelper" do
        assert_methods_registered :baz_uri, :baz_path
        assert_equal "#{base_uri}/baz/form", Shaf::UriHelper.new_baz_uri
        assert_equal "/baz/form", Shaf::UriHelper.new_baz_path
        assert_equal '/baz/form', Shaf::UriHelper.new_baz_path_template
        assert_equal "#{base_uri}/baz/form?bar=5&baz=fem", Shaf::UriHelper.new_baz_uri(bar: 5, baz: "fem")
      end

      it "adds edit_baz_uri method to Shaf::UriHelper" do
        assert_methods_registered :baz_uri, :baz_path
        assert_equal "#{base_uri}/baz/5/edit", Shaf::UriHelper.edit_baz_uri(resrc)
        assert_equal "/baz/5/edit", Shaf::UriHelper.edit_baz_path(resrc)
        assert_equal '/baz/:id/edit', Shaf::UriHelper.edit_baz_path_template
        assert_equal "#{base_uri}/baz/5/edit?bar=5&baz=fem", Shaf::UriHelper.edit_baz_uri(resrc, bar: 5, baz: "fem")
      end

      it "adds path matcher methods" do
        assert_methods_registered(*%i[baz_path? new_baz_path? edit_baz_path?])

        assert Shaf::UriHelper.baz_collection_path? '/baz'
        assert Shaf::UriHelper.baz_path? '/baz/5'
        assert Shaf::UriHelper.new_baz_path? '/baz/form'
        assert Shaf::UriHelper.edit_baz_path? '/baz/5/edit'

        refute Shaf::UriHelper.baz_collection_path? '/nested/baz'
        refute Shaf::UriHelper.baz_collection_path? '/nested/bazs'
        refute Shaf::UriHelper.baz_collection_path? '/baz/5'
        refute Shaf::UriHelper.baz_path? '/baz'
      end
    end

    describe 'skipping some routes' do
      let(:controller) do
        Class.new do
          extend ResourceUris
        end
      end

      it 'only registers the resource helper' do
        controller.resource_uris_for :post, only: :resource
        assert_equal [:post_path], controller.path_helpers
      end

      it 'only registers the resource and new uris' do
        controller.resource_uris_for :post, only: [:resource, :edit]
        assert_matched_arrays [:post_path, :edit_post_path], controller.path_helpers
      end

      it 'registers all but the edit uri' do
        controller.resource_uris_for :post, except: [:edit]
        assert_matched_arrays [:post_path, :posts_path, :new_post_path], controller.path_helpers
      end

      it 'does not register helper with optional parameters when collection is skipped' do
        controller.resource_uris_for :baz, plural_name: :baz, except: [:collection]
        assert_equal(-2, controller.method(:baz_path).arity)
        assert_matched_arrays [:baz_path, :new_baz_path, :edit_baz_path], controller.path_helpers
      end

      it 'does not register helper with optional parameters when resource is skipped' do
        controller.resource_uris_for :baz, plural_name: :baz, only: :collection
        refute controller.respond_to? :baz_path
        assert_equal [:baz_collection_path], controller.path_helpers
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
        assert_equal "hide_book_path_template", builder.send(:template_method_name)
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
