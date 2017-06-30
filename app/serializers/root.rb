require 'models/user'

module Serializers
  class Root
    extend HALDecorator
    extend UriHelper

    #curie :doc, '/docs/{rel}'
    link :self, root_uri
    link :users, users_uri

    embed :'create-user' do
      ::User.create_form.tap do |form|
        form.self_link = new_user_uri
        form.href = users_uri
      end
    end
    embed :'login-form' do
      ::Session.create_form.tap do |form|
        form.self_link = new_session_uri
        form.href = session_uri
      end
    end
  end
end

