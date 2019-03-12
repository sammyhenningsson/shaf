require 'serializers/base_serializer'

class ErrorSerializer < BaseSerializer

  model Shaf::Errors::ServerError

  attribute :title
  attribute :code
  attribute :message

  link :profile do
    Shaf::Settings.error_profile_uri
  end
end
