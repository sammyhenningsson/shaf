class ValidationErrorSerializer < BaseSerializer
  model Shaf::Errors::ValidationError
  profile Shaf::Settings.error_profile_name

  attribute :title
  attribute :code
  attribute :fields do
    resource.fields
  end

  link :profile do
    Shaf::Settings.error_profile_uri
  end
end
