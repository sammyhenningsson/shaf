require 'serializers/base_serializer'

class ErrorSerializer < BaseSerializer
  model Shaf::Errors::ServerError
  profile 'shaf-error'

  attribute :title
  attribute :code
  attribute :message
end
