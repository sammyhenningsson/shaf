# frozen_string_literal: true

def init
  super
  options.resources = YARD::Registry.all(:resource)
  generate_index
  options.resources.each do |resource|
    serialize(resource)
  end
end

def generate_index
  puts 'TODO: generate index.html'
end

def serialize(object)
  options.object = object
  options.serializer ||= serializer
  Templates::Engine.with_serializer(object, options.serializer) do
    T('layout').run(options)
  end
end

def serializer
  YARD::Serializers::FileSystemSerializer.new
end
