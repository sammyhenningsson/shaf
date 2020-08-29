# frozen_string_literal: true

def init
  super

  sections %i[attribute]
end

def value_types
  object.value_types.map do |type|
    {
      type: type,
      class_name: 'profile'
    }
  end
end
