require 'serializers/base_serializer'

class ErrorSerializer < BaseSerializer

  model Shaf::Errors::ServerError

  attribute :title
  attribute :code
  attribute :message

end
