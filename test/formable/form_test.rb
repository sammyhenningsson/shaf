require 'test_helper'
require 'ostruct'

module Shaf
  module Formable
    describe Form do
      let(:form1) do
        Form.new(
          title: 'title',
          action: 'action',
          name: :name,
          method: 'POST',
          type: 'type',
          submit: 'submit',
          fields: {field1: {type: 'string'}}
        )
      end

      it '#dup' do
        form2 = form1.dup
        form1.title = 'title1'
        form1.action = 'action1'
        form1.name = :name1
        form1.method = 'method1'
        form1.type = 'type1'
        form1.add_field('new_field', {})

        assert_equal 'title', form2.title
        assert_equal :action, form2.action
        assert_equal :name, form2.name
        assert_equal 'POST', form2.method
        assert_equal 'type', form2.type
        assert_equal 'submit', form2.submit
        assert_equal 1, form2.fields.size
      end

      it '#clone' do
        form2 = form1.clone
        refute form2.frozen?

        form3 = form1.freeze.clone
        assert form3.frozen?
      end

      it 'sets method from action when :edit' do
        form1 = Form.new(title: 'one', action: :edit)
        form2 = Form.new(title: 'one', action: :create)
        form3 = Form.new(title: 'two')
        form4 = form3.dup
        form4.action = :edit

        assert_equal 'PUT', form1.method
        assert_equal 'POST', form2.method
        assert_nil form3.method
        assert_equal 'PUT', form4.method
      end

      it 'can fill values from resource' do
        form1.add_field(:field2, type: 'string', accessor_name: :model_method)
        resource = OpenStruct.new(field1: 'foo', model_method: 'bar')
        form1.fill!(from: resource)
        fields = form1.fields
        field1 = fields.find { |f| f.name == :field1 }
        _(field1).must_be :has_value?
        _(field1.value).must_equal 'foo'
        field2 = fields.find { |f| f.name == :field2 }
        _(field2).must_be :has_value?
        _(field2.value).must_equal 'bar'
      end
    end
  end
end
