# frozen_string_literal: true

def init
  super

  @attributes = object.attributes
  @relations = object.links

  sections :resource, %i[profile attributes relations]
end

def serialize_attribute(attr)
  Templates::Engine.render(
    template: :api_doc,
    type: :resource_attribute,
    object: attr,
    format: options.format
  )
end

def serialize_relation(rel)
  Templates::Engine.render(
    template: :api_doc,
    type: :resource_relation,
    object: rel,
    format: options.format
  )
end

def name
  object.resource_name
end

def description
  object.description
end

def profile_links
  object.profile_objects.map do |profile_object|

    if profile_object.profile
      path = profile_object.path.sub(/Profiles::/, '')
      href = "/api_doc/#{path}.html"
      css_classes = 'profile'
    else
      href = nil
      css_classes = 'unknown'
    end

    {
      name: profile_object.profile_name,
      href: href,
      css_classes: css_classes
    }
  end
end
