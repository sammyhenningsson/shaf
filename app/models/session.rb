require 'lib/formable'
require 'securerandom'
require 'digest'

class Session < Sequel::Model
  include Formable

  form do
    create do
      title 'Login'
      name 'create-session'
      fields(
        email: { type: "string", label: 'Email'},
        password: { type: "password", label: 'Password'}
      )
    end
  end

  attr_accessor :auth_token

  def initialize(params)
    super
    generate_token
  end

  def generate_token
    @auth_token = SecureRandom.urlsafe_base64
    self.auth_token_digest = Digest::SHA256.hexdigest(@auth_token)
  end

  def valid?
    expire_at > Time.now
  end
end
