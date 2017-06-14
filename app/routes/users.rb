module Routes
  class Users < BaseRoute

    get '/' do
      "hej"
    end

    get '/users' do
      "användare"
    end

    get '/users/:id' do
      User.first!(id: params[:id])
    end
  end
end
