require 'test_helper'

module Integration
  class RootTest < TestCase

    def setup
      payload Serializers::Root.to_hal
    end

    def test_links
      assert_link :self, UriHelper.root_uri
      assert_link :users, UriHelper.users_uri
    end

    def test_embeds_create_user_form
      assert_has_embedded 'create-user'
      embedded :'create-user' do
        assert_link :self, UriHelper.new_user_uri
        assert_attribute :method, 'POST'
        assert_attribute :name, 'create-user'
        assert_attribute :title, 'Create User'
        assert_attribute :href, UriHelper.users_uri
        assert_attribute :type, 'application/json'
        assert_attribute :fields, [
          {
            name: 'username',
            type: 'string',
            label: 'Username'
          },
          {
            name: 'password',
            type: 'password',
            label: 'Password'
          },
          {
            name: 'email',
            type: 'string',
            label: 'Email'
          }
        ]
      end
    end

    def test_embeds_login_form
      assert_has_embedded 'login-form'
      embedded :'login-form' do
        assert_link :self, UriHelper.new_session_uri
        assert_attribute :method, 'POST'
        assert_attribute :name, 'create-session'
        assert_attribute :title, 'Login'
        assert_attribute :href, UriHelper.session_uri
        assert_attribute :type, 'application/json'
        assert_attribute :fields, [
          {
            name: 'email',
            type: 'string',
            label: 'Email'
          },
          {
            name: 'password',
            type: 'password',
            label: 'Password'
          }
        ]
      end
    end

  end
end

