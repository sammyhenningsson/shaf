# frozen_string_literal: true

def init
  super

  options.delete(:serializer)
  sections %i[header sidebar resource footer]
end

def sidebar
  Templates::Engine.render options.merge(type: :sidebar)
end

def resource
  Templates::Engine.render options
end
