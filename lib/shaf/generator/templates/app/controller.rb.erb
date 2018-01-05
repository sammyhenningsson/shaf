class UsersController < BaseController

  resource_uris_for :user

  get '/users/form' do
    form = User.create_form
    form.self_link = new_user_uri
    form.href = users_uri
    respond_with form
  end

  get '/users/:id/edit' do
    form = user.edit_form
    form.self_link = edit_user_uri(user)
    form.href = user_uri(user)
    respond_with form
  end

  get '/users/:id' do
    respond_with user
  end

  put '/users/:id' do
    user.update(user_params)
    respond_with user
  end

  delete '/users/:id' do
    user.destroy
    status 204
  end

  get '/users' do
    respond_with_collection paginate(User.order(:created_at).reverse)
  end

  post '/users' do
    user = User.create(user_params)
    headers({ "Location" => user_uri(user) })
    respond_with user, status: 201
  end

  def user_params
    safe_params(:username, :password, :email)
  end

  def user
    User[params['id']].tap do |user|
      raise ::NotFoundError.new(clazz: User, id: params['id']) unless user
    end
  end

end
