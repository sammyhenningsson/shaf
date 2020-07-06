# frozen_string_literal: true

def init
  super
  @attributes = serialized_attributes
  @relations = serialized_relations

  sections %i[main attributes relations]
end

def serialized_attributes
  options.object.attributes.map do |attribute|
    options = options_for(:attribute, object: attribute)
    Templates::Engine.render options
  end
end

def serialized_relations
  options.object.links.map do |link|
    options = options_for(:link, object: link)
    Templates::Engine.render options
  end
end

def options_for(type, **opts)
  options.merge(
    template: :api_doc,
    type: type,
    **opts
  )
end
