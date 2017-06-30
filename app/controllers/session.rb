class SessionController < BaseController

  register_uri :session,       '/session'
  register_uri :new_session,   '/login/form'

  get '/session' do
    raise ::NotFoundError, "No current session" unless current_session
    respond_with current_session
  end

  delete '/session' do
    raise ::NotFoundError, "No current session" unless current_session
    raise ::ServerError, "Failed to delete session" unless logout
    status 204
  end

  post '/session' do
    if session = current_session
      respond_with extend_session(session)
    elsif session = login(session_params[:email], session_params[:password])
      headers({ "Location" => UriHelper.session_uri })
      respond_with session, status: 201
    else
      redirect back if prefer_html?
      raise ::UnauthorizedError, "Failed to log in"
    end
  end

  get '/login/form' do
    form = Session.create_form
    form.self_link = UriHelper.new_session_uri
    form.href = UriHelper.session_uri
    respond_with form
  end

  def session_params
    safe_params(:email, :password)
  end
end

