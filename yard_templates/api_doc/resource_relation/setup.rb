# frozen_string_literal: true

require 'forwardable'

extend Forwardable

def_delegators :object, :name, :http_methods, :href, :content_type

HTTP_METHODS = %w(head options get put patch post delete).freeze
IANA_HREF = 'https://www.iana.org/assignments/link-relations/link-relations.xhtml'

class Source
  attr_reader :name, :href, :type

  def initialize(name:, href:, type:)
    @name, @href, @type = name, href, type
  end
end

def init
  super

  sections %i[relation]
end

def source
  return @source if defined? @source

  # We currently only support one profile per resource.
  # But this might change in the future.
  profile_objects = [object.profile_object].compact
  profile_objects.each do |profile_object|
    next unless profile_object.profile.find_relation(name)

    path = profile_object.path.sub(/Profiles::/, '')

    @source = Source.new(
      name: profile_object.name,
      href: "/api_doc/#{path}.html",
      type: :profile
    )
    break
  end

  @source ||= iana_source if object.iana_doc
  @source ||= unknown_source
  @source
end

def iana_source
  Source.new(
    name: 'IANA',
    href: IANA_HREF,
    type: :iana
  )
end

def unknown_source
  Source.new(
    name: 'Unknown',
    href: nil,
    type: :unknown
  )
end

def css_classes_for(**options)
  classes = []
  classes.concat http_method_classes(options[:http_method]) if options.key? :http_method
  classes.join(' ' )
end

def http_method_classes(method)
  method = method.to_s.downcase
  css_classes = ['http-method']
  css_classes << method if HTTP_METHODS.include? method
  css_classes
end
