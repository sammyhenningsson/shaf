require 'test_helper'

module Lib
  class FormableTest < MiniTest::Test

    def setup
      @class = Class.new do
        include Formable
      end
    end

    def test_it_adds_form_class_method
      assert @class.respond_to? :form
    end

    def test_creates_duplicate_create_and_edit_forms
      @class.form do
        name 'Foo'
        fields(
          {
            foo: {
              type: "string",
              label: 'Foo'
            },
            bar: {
              type: "string",
              label: 'Bar'
            }
          }
        )
      end
      assert_instance_of(Formable::Form, @class.create_form)
      assert_instance_of(Formable::Form, @class.edit_form)
      refute_equal @class.edit_form.object_id, @class.create_form.object_id
      assert_equal 'Foo', @class.create_form.name
      assert_equal 'Foo', @class.edit_form.name
    end

    def test_creates_create_form
      @class.form do
        create do
          name 'Create Form'
          title 'create-form'
        end
      end

      assert_nil @class.edit_form
      assert_instance_of(Formable::Form, @class.create_form)
      assert_equal 'Create Form', @class.create_form.name
      assert_equal 'create-form', @class.create_form.title
    end

    def test_creates_edit_form
      @class.form do
        edit do
          name 'Edit Form'
          title 'edit-form'
        end
      end

      assert_nil @class.create_form
      assert_instance_of(Formable::Form, @class.edit_form)
      assert_equal 'Edit Form', @class.edit_form.name
      assert_equal 'edit-form', @class.edit_form.title
    end

    def test_creates_different_create_and_edit_forms
      @class.form do
        name 'Common Name'
        create do
          method :post
          type :foo
        end

        edit do
          method :patch
          type :bar
        end
      end
      assert_equal 'Common Name', @class.create_form.name
      assert_equal 'Common Name', @class.edit_form.name
      assert_equal :foo, @class.create_form.type
      assert_equal :bar, @class.edit_form.type
      assert_equal 'POST', @class.create_form.method
      assert_equal 'PATCH', @class.edit_form.method
    end

    def test_instances_can_return_edit_form
      @class.form do
        edit do
          name 'Edit Form'
          title 'edit-form'
        end
      end

      object = @class.new
      assert_instance_of(Formable::Form, object.edit_form)
      assert_equal 'Edit Form', object.edit_form.name
      assert_equal object, object.edit_form.resource
    end

  end
end

