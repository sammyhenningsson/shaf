# frozen_string_literal: true

include Shaf::Yard::NestedAttributes

def init
  super

  @attribute = object
  @nested_attributes = nested_attributes_for(object.descriptor)

  sections %i[attribute] end

def value_types
  object.value_types.map do |type|
    {
      type: type,
      class_name: 'profile'
    }
  end
end
