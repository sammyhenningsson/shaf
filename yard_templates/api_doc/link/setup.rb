# frozen_string_literal: true

def init
  super

  sections %i[relation]
end

def sources
  Array(object.source).compact.map do |src|
    {
      source: src,
      class_name: class_name_for(src)
    }
  end
end

def class_name_for(src)
  if src == Shaf::Yard::LinkObject::SOURCE_IANA
    'iana'
  else
    'profile'
  end
end

def http_methods
  object.http_methods
end

def href
  object.href
end

def content_type
  object.content_type
end
