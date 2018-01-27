require 'test_helper'

describe Shaf::Formable do
  let(:clazz) do
    Class.new do
      include Shaf::Formable
    end
  end

  it "adds form class method" do
    assert clazz.respond_to? :form
  end

  it "creates duplicate create and edit forms" do
    clazz.form do
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
    assert_instance_of(Shaf::Formable::Form, clazz.create_form)
    assert_instance_of(Shaf::Formable::Form, clazz.edit_form)
    refute_equal clazz.edit_form.object_id, clazz.create_form.object_id
    assert_equal 'Foo', clazz.create_form.name
    assert_equal 'Foo', clazz.edit_form.name
  end

  it "creates duplicate create and edit forms" do
    clazz.form do
      name 'Foo'
      field :foo, type: "string", label: 'Foo'
      field :bar, type: "string", label: 'Bar'
    end
    assert_instance_of(Shaf::Formable::Form, clazz.create_form)
    assert_instance_of(Shaf::Formable::Form, clazz.edit_form)
    refute_equal clazz.edit_form.object_id, clazz.create_form.object_id
    assert_equal 'Foo', clazz.create_form.name
    assert_equal 'Foo', clazz.edit_form.name
    assert_equal [:foo, :bar], clazz.create_form.fields.map(&:name)
  end

  it "creates a create form" do
    clazz.form do
      create do
        name 'Create Form'
        title 'create-form'
      end
    end

    assert_nil clazz.edit_form
    assert_instance_of(Shaf::Formable::Form, clazz.create_form)
    assert_equal 'Create Form', clazz.create_form.name
    assert_equal 'create-form', clazz.create_form.title
  end

  it "creates a edit form" do
    clazz.form do
      edit do
        name 'Edit Form'
        title 'edit-form'
      end
    end

    assert_nil clazz.create_form
    assert_instance_of(Shaf::Formable::Form, clazz.edit_form)
    assert_equal 'Edit Form', clazz.edit_form.name
    assert_equal 'edit-form', clazz.edit_form.title
  end

  it "creates different create and edit forms" do
    clazz.form do
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
    assert_equal 'Common Name', clazz.create_form.name
    assert_equal 'Common Name', clazz.edit_form.name
    assert_equal :foo, clazz.create_form.type
    assert_equal :bar, clazz.edit_form.type
    assert_equal 'POST', clazz.create_form.method
    assert_equal 'PATCH', clazz.edit_form.method
  end

  it "is possible to get the edit form from instances" do
    clazz.form do
      edit do
        name 'Edit Form'
        title 'edit-form'
      end
    end

    object = clazz.new
    assert_instance_of(Shaf::Formable::Form, object.edit_form)
    assert_equal 'Edit Form', object.edit_form.name
    assert_equal object, object.edit_form.resource
  end
end
