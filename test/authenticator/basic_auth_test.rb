require 'test_helper'
require 'ostruct'

module Shaf
  module Authenticator
    describe BasicAuth do
      let(:cred) { ['foo:foo'].pack('m*').chomp }
      let(:request) do
        Request.new('HTTP_AUTHORIZATION' => "Basic #{cred}")
      end


      before do
        BasicAuth.restricted realm: 'r1' do |user, password|
          OpenStruct.new(realm: realm, user: user, password: password) if user == password
        end
        BasicAuth.restricted realm: 'r2' do |user, password|
          OpenStruct.new(realm: realm, user: user, password: password) if user == password
        end
      end

      it "parses credentials" do
        credentials = BasicAuth.credentials(cred, nil)
        assert_equal ['foo', 'foo'], credentials
      end

      it "returns a user when credentials is correct" do
        user = BasicAuth.user(request)
        assert user
        assert_equal 'foo', user.user
      end

      it "returns a user for the correct realm" do
        user = BasicAuth.user(request, realm: 'r2')
        assert user
        assert_equal 'foo', user.user
        assert_equal 'r2', user.realm
      end

      it "returns nil when credentials is incorrect" do
        cred = ['foo:bar'].pack('m*').chomp
        request = Request.new('HTTP_AUTHORIZATION' => "Basic #{cred}")
        refute BasicAuth.user(request)
      end
    end
  end
end
