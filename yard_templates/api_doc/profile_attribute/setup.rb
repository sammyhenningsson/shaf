# frozen_string_literal: true

def init
  super

  @attribute = options.object

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
