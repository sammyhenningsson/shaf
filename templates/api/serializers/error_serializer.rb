require 'serializers/base_serializer'

class ErrorSerializer < BaseSerializer
  model Shaf::Errors::ServerError
  profile Shaf::Settings.error_profile_name

  attribute :title
  attribute :code
  attribute :message

  link :profile do
    Shaf::Settings.error_profile_uri
  end
end
