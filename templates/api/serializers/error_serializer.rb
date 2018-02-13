class ErrorSerializer
  extend HALPresenter

  model Shaf::Errors::ServerError

  attribute :title
  attribute :code
  attribute :message

end
