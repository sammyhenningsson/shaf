require 'test_helper'

describe Shaf::Formable do
  let(:clazz) do
    Class.new do
      include Shaf::Formable
    end
  end

  it 'adds form class method' do
    assert clazz.respond_to? :form
  end

  it 'creates a create form' do
    clazz.form do
      title 'Create Form'
      action :create
    end

    assert_instance_of(Shaf::Formable::Form, clazz.create_form)
    assert_equal 'Create Form', clazz.create_form.title
    assert_equal :'create-form', clazz.create_form.name
    assert_equal :create, clazz.create_form.action
  end

  it 'creates a create form from a nested block' do
    clazz.form do
      create do
        title 'Create Form'
        action :create
      end
    end

    assert_instance_of(Shaf::Formable::Form, clazz.create_form)
    assert_equal 'Create Form', clazz.create_form.title
    assert_equal :'create-form', clazz.create_form.name
    assert_equal :create, clazz.create_form.action
  end

  it 'does not create a create form without action' do
    clazz.form do
      title 'Create Form'
    end

    assert_empty clazz.singleton_methods.grep(/_form/)
  end

  it 'is possible to set name' do
    clazz.form do
      title 'Create Form'
      action :create
      name :"foo-form"
    end

    assert_instance_of(Shaf::Formable::Form, clazz.create_form)
    assert_equal :'foo-form', clazz.create_form.name
  end

  it 'creates an edit form' do
    clazz.form do
      edit do
        title 'Edit Form'
        action :edit
      end
    end

    assert_instance_of(Shaf::Formable::Form, clazz.edit_form)
    assert_equal 'Edit Form', clazz.edit_form.title
    assert_equal :'edit-form', clazz.edit_form.name
    assert_equal :edit, clazz.edit_form.action
  end

  it 'creates different create and edit forms' do
    clazz.form do
      title 'Common label'
      create do
        method :post
        type :foo
      end

      edit do
        method :patch
        type :bar
      end
    end

    create_form = clazz.create_form
    edit_form = clazz.edit_form

    assert_equal 'Common label', create_form.title
    assert_equal 'Common label', edit_form.title
    assert_equal 'POST', create_form.method
    assert_equal 'PATCH', edit_form.method
    assert_equal :foo, create_form.type
    assert_equal :bar, edit_form.type
  end

  it 'is possible to get the edit form from instances' do
    clazz.form do
      edit do
        title 'Edit Form'
        action :edit
        instance_accessor
      end
    end

    object = clazz.new
    assert_instance_of(Shaf::Formable::Form, object.edit_form)
    assert_equal 'Edit Form', object.edit_form.title
    assert_equal object, object.edit_form.resource
  end
end
