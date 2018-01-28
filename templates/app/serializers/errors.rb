module Serializers
  class Error
    extend HALPresenter

    model Error

    attribute :title
    attribute :code
    attribute :message

  end
end

