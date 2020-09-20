# frozen_string_literal: true

include Shaf::Yard::NestedAttributes

def init
  super

  @attribute = object
  @nested_attributes = nested_attributes_for(object)

  sections %i[attribute]
end

def value_types
  Array(@attribute&.type).compact.map do |type|
    {
      type: type.to_s,
      class_name: 'profile'
    }
  end
end
