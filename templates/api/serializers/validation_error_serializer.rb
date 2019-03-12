class ValidationErrorSerializer < BaseSerializer
  model Shaf::Errors::ValidationError

  attribute :title
  attribute :code
  attribute :fields do
    resource.fields
  end

  link :profile do
    Shaf::Settings.error_profile_uri
  end
end
