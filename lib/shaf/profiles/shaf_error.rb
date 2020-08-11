# frozen_string_literal: true

module Shaf
  module Profiles
    class ShafError < Shaf::Profile
      name 'shaf-error'

      doc  'This profile describes a set of descriptors for generic error messages.'
      example <<~EXAMPLE
      {
        "title": "Invalid entity",
        "message": "The user could not be saved, due to unfulfilled requirements",
        "code": "VALIDATION_ERROR",
        "fields": {
          "email": ["cannot be empty"]
        }
      }
      EXAMPLE

      example <<~EXAMPLE
      {
        "title": "Unpermitted action",
        "message": "User is not allowed to edit this resource",
        "code": "FORBIDDEN_ERROR",
      }
      EXAMPLE

      attribute :code,
        type: :string,
        doc: 'An identifier that describes the type of error.'

      attribute :title,
        type: :string,
        doc: 'A short string used for labeling the error.'

      attribute :message,
        type: :string,
        doc: 'A description with details about the error.'

      attribute :fields,
        type: :string,
        doc: 'An object describing validation errors. ' \
             'The keys correspond to attributes of a resource. ' \
             'The values are an array of strings describing validation errors ' \
             'for the corresponding attribute.'
    end
  end
end
