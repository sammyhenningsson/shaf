require 'test_helper'

module Serializer
  class UserTest < TestCase

    def setup
      @user = User.create(
        username: 'test_user',
        password: 'hidden',
        email: 'test@user.com',
      )
      @another_user = User.create(
        username: 'test_another',
        password: 'hidden',
        email: 'another@user.com',
      )
    end

    def test_unauthenticated
      payload HALDecorator.to_hal(@user, current_user: nil)

      assert_attribute :username, 'test_user'
      assert_attribute :email, 'test@user.com'
      assert_link :self, UriHelper.user_uri(@user)
      refute_has_links :edit, :delete, 'edit-form'
    end

    def test_current_user
      payload HALDecorator.to_hal(@user, current_user: @user)

      assert_attribute :username, 'test_user'
      assert_attribute :email, 'test@user.com'
      assert_link :self, UriHelper.user_uri(@user)
      assert_has_links :edit, :delete, 'edit-form'
    end

    def test_other_user
      payload HALDecorator.to_hal(@user, current_user: @another_user)

      assert_attribute :username, 'test_user'
      assert_attribute :email, 'test@user.com'
      assert_link :self, UriHelper.user_uri(@user)
      refute_has_links :edit, :delete, 'edit-form'
    end
  end
end

