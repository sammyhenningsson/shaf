require 'test_helper'

describe Shaf::Formable do
  let(:clazz) { Class.new }
  let(:subject) do
    Class.new do
      extend Shaf::Formable
    end
  end

  it 'adds form_for class method' do
    assert subject.respond_to? :form_for
  end

  it 'creates a create form' do
    subject.forms_for(clazz) do
      title 'Create Form'
      action :create
    end

    assert_instance_of(Shaf::Formable::Form, clazz.create_form)
    assert_equal 'Create Form', clazz.create_form.title
    assert_equal :'create-form', clazz.create_form.name
    assert_equal :create, clazz.create_form.action
  end

  it 'creates a create form from a nested block' do
    subject.form_for(clazz) do
      create_form do
        title 'Create Form'
      end
    end

    assert_instance_of(Shaf::Formable::Form, clazz.create_form)
    assert_equal 'Create Form', clazz.create_form.title
    assert_equal :'create-form', clazz.create_form.name
    assert_equal :create, clazz.create_form.action
  end

  it 'adds _form when not provided (legacy)' do
    subject.form_for(clazz) do
      create do
        title 'Create Form'
      end
    end

    assert_instance_of(Shaf::Formable::Form, clazz.create_form)
    assert_equal 'Create Form', clazz.create_form.title
    assert_equal :'create-form', clazz.create_form.name
    assert_equal :create, clazz.create_form.action
  end

  it 'can override action' do
    subject.form_for(clazz) do
      create_form do
        title 'Some form'
        action 'archive'
      end
    end

    assert_instance_of(Shaf::Formable::Form, clazz.create_form)
    assert_equal 'Some form', clazz.create_form.title
    assert_equal :'archive-form', clazz.create_form.name
    assert_equal :archive, clazz.create_form.action
  end

  it 'does not create a create form without action' do
    subject.form_for(clazz) do
      title 'Create Form'
    end

    assert_empty clazz.singleton_methods.grep(/_form/)
  end

  it 'is possible to set name' do
    subject.form_for(clazz) do
      title 'Create Form'
      action :create
      name :"foo-form"
    end

    assert_instance_of(Shaf::Formable::Form, clazz.create_form)
    assert_equal :'foo-form', clazz.create_form.name
  end

  it 'is possible to set submit' do
    subject.form_for(clazz) do
      title 'Create Form'
      action :create
      submit :spara
    end

    assert_instance_of(Shaf::Formable::Form, clazz.create_form)
    assert_equal :spara, clazz.create_form.submit
  end

  it 'creates an edit form' do
    subject.form_for(clazz) do
      edit_form do
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
    subject.forms_for(clazz) do
      title 'Common label'
      create_form do
        method :post
        type :foo
      end

      edit_form do
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
    subject.form_for(clazz) do
      edit_form do
        title 'Edit Form'
        instance_accessor
      end
    end

    object = clazz.new
    assert_instance_of(Shaf::Formable::Form, object.edit_form)
    assert_equal 'Edit Form', object.edit_form.title
    assert_equal object, object.edit_form.resource
  end

  it 'prefills form from an instance' do
    clazz.define_method(:foo) { 5 }

    subject.form_for(clazz) do
      some_form do
        instance_accessor prefill: true
        field :bar, accessor_name: :foo
      end
    end

    object = clazz.new
    assert_equal 5, object.some_form[:bar].value

    # Form from class is still empty
    assert_nil clazz.some_form[:bar].value
  end

  it 'returns an empty form from an instance' do
    clazz.define_method(:foo) { 5 }

    subject.form_for(clazz) do
      some_form do
        instance_accessor prefill: false
        field :foo
      end
    end

    object = clazz.new
    assert_nil object.some_form[:foo].value
  end
end
