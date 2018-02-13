class RootController < BaseController

  register_uri :root,    '/'

  get '/' do
    respond_with nil, serializer: RootSerializer
  end
end
