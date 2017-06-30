require 'lib/formable'

class User < Sequel::Model
  include Formable

  form do
    fields(
      username: { type: "string",   label: 'Username'},
      password: { type: "password", label: 'Password'},
      email:    { type: "string",   label: 'Email'},
    )

    create do
      title 'Create User'
      name  'create-user'
    end

    edit do
      title 'Update User'
      name  'update-user'
    end
  end

  def self.create(params)
    replace_password! params
    super(params)
  end

  def self.update(params)
    replace_password! params
    super(params)
  end

  def self.replace_password!(params)
    params.delete(:password_digest)
    password = params.delete(:password)
    params[:password_digest] = BCrypt::Password.create(password) if password
    params
  end

  def update(params)
    self.class.replace_password!(params)
    super params
  end

end

