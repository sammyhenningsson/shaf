# frozen_string_literal: true

require 'set'

def init
  super

  @resources = resources
  @profiles = profiles

  sections :sidebar, %i[serializer_list profile_list]
end

def resources
  options.resources.map do |resource|
    path = resource.path.sub(/Serializers::/, '')

    {
      name: resource.resource_name,
      path: "/api_doc/#{path}.html"
    }
  end.sort_by { |h| h[:name] }
end

def profiles
  options.profiles.map do |profile|
    path = profile.path.sub(/Profiles::/, '')

    {
      name: profile.profile_name,
      path: "/api_doc/#{path}.html"
    }
  end.sort_by { |h| h[:name] }
end

def profile?
  object.is_a? Shaf::Yard::ProfileObject
end

def resource?
  object.is_a? Shaf::Yard::ResourceObject
end

def index?
  object.type == :doc_index
end

def resource_active?(name)
  return false unless resource?
  object.resource_name == name
end

def profile_active?(name)
  return false unless profile?
  object.profile_name == name
end
