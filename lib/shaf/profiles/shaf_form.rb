# frozen_string_literal: true

module Shaf
  module Profiles
    class ShafForm < Shaf::Profile
      name 'shaf-form'

      doc 'This profile describes how a set of descriptors should be interpreted to ' \
          'turn a generic media type into a form (similar to HTML forms). For ' \
          'example, the HAL media type (application/hal+json) does not specify any ' \
          'semantics about forms, however we can add semantics about forms to a HAL ' \
          'document using this profile.'

      example <<~EXAMPLE
        Given the following form:

        ```json
          "create-form": {
            "method": "POST",
            "name": "create-post",
            "title": "Create Post",
            "href": "/posts",
            "type": "application/json",
            "_links": {
              "self": {
                "href": "http://localhost:3000/posts/form"
              }
            },
            "fields": [
              {
                "name": "title",
                "type": "string",
              },
              {
                "name": "message",
                "type": "string",
              }
            ]
          }
        ```

        A client should then present a user interface with the possiblity to fill in two fields accepting string values (if applicable the interface should be titled "Create Post"). The entered values should be mapped to the keys title resp. message. (The client may of course fill in the details itself whenever possible). When the form is to be submitted, the client constructs a json string with the keys and values and makes a POST request to http://localhost:3000/posts/form with the header Content-Type header set to application/json and the json string as body.

        Using Curl, the form above could be submitted using:

        ```sh
          curl -H "Content-Type: application/json" \
               -X POST \
               -d '{"title": "hello", "message": "world"}' \
               localhost:3000/posts
        ```
      EXAMPLE

      attribute :method,
        type: :string,
        doc: 'The HTTP method used for submitting the form'

      attribute :href,
        type: :string,
        doc: 'The target uri that the form should be submitted to'

      attribute :name,
        type: :string,
        doc: 'A string used to indentify the form.'

      attribute :title,
        type: :string,
        doc: 'A string used as title/label when showing the form in a user interface'

      attribute :type,
        type: :string,
        doc: 'The media type that must be set in the CONTENT-TYPE header when submiting the form'

      attribute :submit,
        type: :string,
        doc: 'A string used as label for the CallToAction (e.g. the submit button text)'

      FIELD_DOC = 'A list of field descriptors'
      attribute :fields, doc: FIELD_DOC do

        attribute :name,
                  type: :string,
                  doc: 'A string that should be used as key for the field.'

        attribute :type,
                  type: :string,
                  doc: 'A string specifying the possible values accepted by the field.'

        attribute :title,
                  type: :string,
                  doc: 'A string used to present this field in a UI. If not present name may be used instead.'

        attribute :value,
                  doc: 'A prefilled value. Should be shown in a user interface (unless hidden) and sent back on submission unless changed.'

        attribute :required,
                  type: :boolean,
                  doc: 'A boolean specifying that the field must be given a value before the form is submitted.'

        attribute :hidden,
                  type: :boolean,
                  doc: 'A boolean specifying that the field should not be shown in a user interface.'

        attribute :accepted_values,
                  type: :array,
                  doc: 'A list of av acceptable values. Submitting a value not present in this list SHOULD result in a client error response.'
      end
    end
  end
end
