module Serializers
  class Error
    extend HALDecorator

    model Error

    attribute :title
    attribute :code
    attribute :message

  end
end

