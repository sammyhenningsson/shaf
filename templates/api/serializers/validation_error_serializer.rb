class ValidationErrorSerializer < BaseSerializer
  model Shaf::Errors::ValidationError
  profile 'shaf-error'

  attribute :title
  attribute :code
  attribute :fields do
    resource.fields
  end
end
