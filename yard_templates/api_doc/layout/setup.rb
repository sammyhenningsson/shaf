# frozen_string_literal: true

def init
  super

  options.delete(:serializer)
  # sections :layout, %i[header sidebar resource footer]
  sections :layout, %i[header sidebar resource]
end

def sidebar
  Templates::Engine.render options.merge(type: :sidebar)
end

def resource
  Templates::Engine.render options
end

def project_name
  'Foobar'
end

def title
  "#{project_name} API Documentation"
end
