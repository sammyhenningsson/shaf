require 'models/session'

module Serializers
  class Session
    extend HALDecorator
    extend UriHelper

    model ::Session

    attribute :auth_token
    attribute :created_at
    attribute :expire_at

    link :self do
      session_uri
    end

    link :user do
      user_uri(resource.user_id)
    end

    link :'logout' do
      session_uri
    end

  end
end
