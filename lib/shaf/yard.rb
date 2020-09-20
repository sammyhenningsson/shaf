# frozen_string_literal: true

require 'yard'
require 'shaf/yard/serializer_handler'
require 'shaf/yard/attribute_method_handler'
require 'shaf/yard/link_method_handler'
require 'shaf/yard/profile_method_handler'
require 'shaf/yard/resource_object'
require 'shaf/yard/profile_object'
require 'shaf/yard/attribute_object'
require 'shaf/yard/link_object'
require 'shaf/yard/nested_attributes'
require 'shaf/yard/parser'

module Shaf
  module Yard
    CUSTOM_TAGS = [
      ['Request Header', :request_header, :with_name],
      ['Reponse Header', :response_header, :with_name],
      ['Example Request', :example_request],
      ['Example Response', :example_response],
      ['Description', :description],
      ['HTTP method', :http_method],
      ['Attribute type', :type, :with_types]
    ].freeze

    CUSTOM_TAGS.each do |tag|
      YARD::Tags::Library.define_tag(*tag)
    end

    TEMPLATE_PATH = File.join(Utils.gem_root, 'yard_templates').freeze
    YARD::Templates::Engine.register_template_path TEMPLATE_PATH
  end
end
