require 'serializers/base_serializer'
require 'shaf/formable'

class ProfileSerializer < BaseSerializer

  model Shaf::Profile
  # profile ALPS

  attribute :attributes do
    resource.attributes.map  do |attr|
      {
        name: attr.name,
        doc: attr.doc,
        type: attr.type
      }
    end
  end

  attribute :relations do
    resource.relations.map  do |rel|
      {
        name: rel.name,
        doc: rel.doc,
        http_method: rel.http_method,
        payload_type: rel.payload_type,
        content_type: rel.content_type,
      }
    end
  end

  link :self do
    profile_path(resource.name)
  end

  link :profile do
    'alps.io....'
  end
end
