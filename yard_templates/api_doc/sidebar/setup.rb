# frozen_string_literal: true

require 'set'

def init
  super

  @serializers = serializers
  @profiles = profiles

  sections %i[search serializer_list profile_list]
end

def serializers
  options.resources.map(&:resource_name)
end

def profiles
  options.resources.each_with_object(Set.new) do |serializer, profiles|
    profile = serializer.profile
    profiles << profile.name if profile
  end.to_a
end
