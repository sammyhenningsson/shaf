require 'test_helper'

module Model
  class SessionTest < TestCase
    include SessionsHelper

    def setup
      @user = User.create(
        username: 'test_user',
        email: 'test_create@session.com',
        password: 'hidden',
      )
    end

    def test_login
      @env["REQUEST_METHOD"] = 'POST'
      session = login(@user.email, 'hidden')
      assert session
      assert session.valid?
      assert_equal @user.id, session.user_id
      assert session.auth_token_digest
      assert session.auth_token
      refute_equal session.auth_token, session.auth_token_digest
      refute_equal 'hidden', session.auth_token_digest
    end

  end
end

