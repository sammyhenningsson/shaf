# frozen_string_literal: true

require 'forwardable'

extend Forwardable
include Shaf::Yard::NestedAttributes

def_delegators :object, :name, :http_methods, :href, :content_type

HTTP_METHODS = %w(head options get put patch post delete).freeze

def init
  super

  @relation = object
  @nested_attributes = nested_attributes_for(object)

  sections %i[relation]
end

def value_types
  Array(@attribute&.type).compact.map do |type|
    {
      type: type.to_s,
      class_name: 'profile'
    }
  end
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
