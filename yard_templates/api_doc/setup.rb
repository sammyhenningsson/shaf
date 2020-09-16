# frozen_string_literal: true

require 'shaf/profiles'

def init
  super

  init_options
end

def init_options
  options.resources = YARD::Registry.all(:resource)
  options.profiles = YARD::Registry.all(:profile)
end

def serializer(base_path: nil)
  YARD::Serializers::FileSystemSerializer.new.tap do |serializer|
    base_path ||= self.base_path
    serializer.basepath = base_path
  end
end

def base_path
  "#{public_path}/api_doc"
end

def public_path
  path = String(Shaf::Settings.public_folder)
  return 'public' if path.empty?
  path
end
