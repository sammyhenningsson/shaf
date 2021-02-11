# frozen_string_literal: true

def init
  super
  return unless object

  sections :layout, %i[header sidebar main footer]
end

def sidebar
  Templates::Engine.render options.merge(type: :sidebar)
end

def main
  Templates::Engine.render options
end

def sub_title
  'API documentation'
end

def title
  Shaf::Settings.project_name
end
