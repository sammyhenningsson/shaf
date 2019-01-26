require 'test_helper'

module Shaf
  module Generator
    module Migration
      describe Type do
        let(:type) do
          Type.new(
            'foo',
            create_template: 'Integer :%s',
            alter_template: 'add_column :%s, Integer'
          )
        end
        let(:foreign_type) do
          Type.new(
            'foo',
            create_template: 'foreign_key :%s, :%s',
            alter_template: 'add_foreign_key :%s, :%s'
          )
        end

        it 'can find a type' do
          assert Type.find('integer')
        end

        it '#find returns nil when type not found' do
          assert_nil Type.find('foobar')
        end

        it 'returns a formatted create string' do
          formatted = type.build('car', create: true)
          assert_equal 'Integer :car', formatted
        end

        it 'returns a formatted alter string' do
          formatted = type.build('car:integer', alter: true)
          assert_equal 'add_column :car, Integer', formatted
        end

        it 'can take extra arguments' do
          formatted = foreign_type.build('car_id:foreign_key,cars', create: true)
          assert_equal 'foreign_key :car_id, :cars', formatted

          formatted = foreign_type.build('car_id:foreign_key,cars', alter: true)
          assert_equal 'add_foreign_key :car_id, :cars', formatted
        end

        it 'raise exception when wrong number of args given' do
          assert_raises Command::ArgumentError do
            foreign_type.build('car_id', create: true)
          end
        end

        describe '#validate!' do
          let(:type) do
            Type.new(
              'foo',
              create_template: 'foreign_key :%s, :%s',
              alter_template: 'add_foreign_key :%s, :%s',
              validator: ->(type, *args) {
                "no go" if args.first == "raise"
              }
            )
          end

          it 'does not raise exception when validation returns nil' do
            formatted = type.build('car_id:foo,cars', alter: true)
            assert_equal 'add_foreign_key :car_id, :cars', formatted
          end

          it 'raise exception when validation returns error' do
            assert_raises RuntimeError do
              type.build('raise:foo')
            end
          end
        end
      end
    end
  end
end
