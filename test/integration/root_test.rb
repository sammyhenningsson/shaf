require 'test_helper'

module Integration
  class RootTest < TestCase

    def setup
      get UriHelper.root_uri
      assert last_response.ok?
    end

    def test_status_code
      assert_status 200
    end

    def test_links
      assert_has_links :self, :users
    end

    def test_embeds_forms
      assert_has_embedded 'create-user'
      assert_has_embedded 'login-form'
    end

  end
end

