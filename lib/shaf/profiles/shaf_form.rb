
module Shaf
  module Profiles
    class ShafForm < Shaf::Profile
      name 'shaf-form'

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
