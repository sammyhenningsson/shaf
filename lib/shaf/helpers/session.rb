require 'digest'

module Shaf
  module Session

    SESSION_TTL = 60 * 60 * 24 * 2 # 2 days

    def login(email, password)
      return unless email && password
      user = User.first(email: email) or return
      bcrypt = BCrypt::Password.new(user.password_digest)
      return unless bcrypt == password
      @current_user = user

      Session.where(user_id: user.id).delete
      params = {
        user_id: user.id,
        expire_at: Time.now + SESSION_TTL,
      }
      Session.create(params)
    end

    def extend_session(session)
      return unless session
      session.update(expire_at: Time.now + SESSION_TTL)
      session.auth_token = request.env['HTTP_X_AUTH_TOKEN']
      session
    end

    def logout
      current_session&.destroy
    end

    def current_user
      unless defined?(@current_user) && @current_user
        return unless request.env.key? 'HTTP_X_AUTH_TOKEN'
        digest = Digest::SHA256.hexdigest(request.env['HTTP_X_AUTH_TOKEN'])
        session = Session.where(auth_token_digest: digest).first
        @current_user = User[session.user_id] if session&.valid?
      end
      @current_user
    end

    def current_session
      unless @current_session
        return unless current_user
        @current_session = Session.where(user_id: current_user.id).first
      end
      @current_session
    end

  end
end
