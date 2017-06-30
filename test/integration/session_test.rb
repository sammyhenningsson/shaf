require 'test_helper'

module Integration
  class SessionTest < TestCase

    def setup
      @user = User.create(
        username: 'user_a',
        password: 'hemligt',
        email: 'user@a.com'
      )
      User.create(
        username: 'user_b',
        password: 'hemligt',
        email: 'user@b.com'
      )
    end

    def test_get_without_token
      get UriHelper.session_uri
      assert_status 404
    end

    def test_get_with_incorrect_token
      header 'X-AUTH-TOKEN', 'foo'
      get UriHelper.session_uri
      assert_status 404
    end

    def test_get_with_correct_token
      login('user@a.com', 'hemligt')
      get UriHelper.session_uri
      assert_status 200

      assert_has_attributes :created_at, :expire_at

      assert_link :self, UriHelper.session_uri
      assert_link :user, UriHelper.user_uri(@user)
      assert_link :logout, UriHelper.session_uri
    end

    def test_create_with_invalid_credentials
      data = JSON.generate(
        {
          email: 'user@b.com',
          password: 'hemligttt'
        }
      )
      header 'Content-Type', 'application/json'
      post UriHelper.session_uri, data
      assert_status 401
    end

    def test_create_with_valid_credentials
      data = JSON.generate(
        {
          email: 'user@a.com',
          password: 'hemligt'
        }
      )
      header 'Content-Type', 'application/json'
      post UriHelper.session_uri, data
      assert_status 201
      assert_header 'Location', UriHelper.session_uri
      assert_has_attributes :auth_token, :created_at, :expire_at
      assert_link :self, UriHelper.session_uri
      assert_link :user, UriHelper.user_uri(@user)
      assert_link :logout, UriHelper.session_uri
    end

    def test_update_without_token
      header 'Content-Type', 'application/json'
      post UriHelper.session_uri
      assert_status 401
    end

    def test_update_with_invalid_token
      header 'X-AUTH-TOKEN', "foo"
      post UriHelper.session_uri
      assert_status 401
    end

    def test_update
      login('user@a.com', 'hemligt')
      post UriHelper.session_uri
      assert_status 200
      assert_has_attributes :auth_token, :created_at, :expire_at
      assert_link :self, UriHelper.session_uri
      assert_link :user, UriHelper.user_uri(@user)
      assert_link :logout, UriHelper.session_uri
    end

    def test_delete_without_token
      delete UriHelper.session_uri
      assert_status 404
    end

    def test_delete_with_invalid_token
      header 'X-AUTH-TOKEN', "foo"
      delete UriHelper.session_uri
      assert_status 404
    end

    def test_delete_with_valid_token
      login('user@a.com', 'hemligt')
      delete UriHelper.session_uri
      assert_status 204

      get UriHelper.session_uri
      assert_status 404
    end

    def test_get_form
      get UriHelper.new_session_uri
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

