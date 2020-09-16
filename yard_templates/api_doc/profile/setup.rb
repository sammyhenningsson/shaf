# frozen_string_literal: true

def init
  super

  return unless object.profile

  @attributes = object.profile.attributes
  @relations = object.profile.relations

  sections :profile, [:attributes, :relations]
end

def serialize_attribute(attr)
  Templates::Engine.render(
    template: :api_doc,
    type: :profile_attribute,
    object: attr,
    format: options.format
  )
end

def serialize_relation(rel)
  Templates::Engine.render(
    template: :api_doc,
    type: :profile_relation,
    object: rel,
    format: options.format
  )
end

def name
  object.profile_name
end

def description
  object.description
end
