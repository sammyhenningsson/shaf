module Serializer
  class SessionTest < TestCase

    def setup
      @user = User.create(
        username: 'test_user',
        password: 'hidden',
        email: 'test@user.com',
      )
      @session = Session.create(
        user_id: @user.id,
        expire_at: Time.now + SessionsHelper::SESSION_TTL,
      )
    end

    def test_serialize_session
      payload HALDecorator.to_hal(@session, current_user: @user)

      assert_attribute :auth_token, @session.auth_token
      assert_attribute :created_at, @session.created_at.to_s
      assert_attribute :expire_at, @session.expire_at.to_s
      assert_has_links :self, :user, :logout
    end
  end
end


