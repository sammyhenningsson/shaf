require 'test_helper'

module Shaf
  module Formable
    describe Form do
      let(:form1) do
        Form.new(
          title: 'title',
          action: 'action',
          name: 'name',
          method: 'POST',
          type: 'type',
          fields: {field_name: {type: 'string'}}
        )
      end

      it '#dup' do
        form2 = form1.dup
        form1.title = 'title1'
        form1.action = 'action1'
        form1.name = 'name1'
        form1.method = 'method1'
        form1.type = 'type1'
        form1.add_field('new_field', {})

        assert_equal 'title', form2.title
        assert_equal 'action', form2.action
        assert_equal 'name', form2.name
        assert_equal 'POST', form2.method
        assert_equal 'type', form2.type
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
    end
  end
end
