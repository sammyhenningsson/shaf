require 'test_helper'

describe Shaf::Formable do
  before do
    @class = Class.new do
      include Shaf::Formable
    end
  end

  it "adds form class method" do
    assert @class.respond_to? :form
  end

  it "creates duplicate create and edit forms" do
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
    assert_instance_of(Shaf::Formable::Form, @class.create_form)
    assert_instance_of(Shaf::Formable::Form, @class.edit_form)
    refute_equal @class.edit_form.object_id, @class.create_form.object_id
    assert_equal 'Foo', @class.create_form.name
    assert_equal 'Foo', @class.edit_form.name
  end

  it "creates a create form" do
    @class.form do
      create do
        name 'Create Form'
        title 'create-form'
      end
    end

    assert_nil @class.edit_form
    assert_instance_of(Shaf::Formable::Form, @class.create_form)
    assert_equal 'Create Form', @class.create_form.name
    assert_equal 'create-form', @class.create_form.title
  end

  it "creates a edit form" do
    @class.form do
      edit do
        name 'Edit Form'
        title 'edit-form'
      end
    end

    assert_nil @class.create_form
    assert_instance_of(Shaf::Formable::Form, @class.edit_form)
    assert_equal 'Edit Form', @class.edit_form.name
    assert_equal 'edit-form', @class.edit_form.title
  end

  it "creates different create and edit forms" do
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

  it "is possible to get the edit form from instances" do
    @class.form do
      edit do
        name 'Edit Form'
        title 'edit-form'
      end
    end

    object = @class.new
    assert_instance_of(Shaf::Formable::Form, object.edit_form)
    assert_equal 'Edit Form', object.edit_form.name
    assert_equal object, object.edit_form.resource
  end
end
