# frozen_string_literal: true

def init
  super

  setup_options

  generate_index
  generate_assets

  options.resources.each do |resource|
    serialize(resource)
  end
end


def setup_options
  options.resources = YARD::Registry.all(:resource)
  options.serializer ||= serializer
end

def generate_index
  puts 'TODO: generate index.html'
end

def generate_assets
  serializer = options.serializer.dup
  serializer.basepath = asset_base_path

  assets.each do |asset|
    content = file(asset)
    serializer.serialize(asset, content)
  end
end

def serialize(object)
  options.object = object
  Templates::Engine.with_serializer(object, options.serializer) do
    T('layout').run(options)
  end
end

def serializer
  YARD::Serializers::FileSystemSerializer.new
end

def assets
  [
    'js/switch_tab.js',
    'css/api-doc.css',
  ]
end

def asset_base_path
  'frontend/assets'
end
