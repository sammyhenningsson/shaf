# frozen_string_literal: true

require 'ostruct'
require 'shaf/yard/profile_object'

def init
  super

  generate_index
  generate_assets
  generate_resources
  generate_profiles
end

def generate_index
  serialize(index_object)
end

def index_object
  OpenStruct.new(
    path: :index,
    name: :index,
    type: :doc_index
  )
end

def generate_assets
  Array(assets).each do |asset|
    content = file(asset)
    serializer(base_path: public_path).serialize(asset, content)
  end
end

def generate_resources
  options.resources.each do |resource|
    serialize(resource)
  end
end

def generate_profiles
  options.profiles.each do |profile|
    serialize(profile)
  end
end

def serialize(object)
  options.object = object
  Templates::Engine.with_serializer(object, serializer) do
    T('layout').run(options)
  end
end

def assets
  [
    'css/api-doc.css',
    'js/switch_tab.js',
    'favicon.ico',
  ]
end
