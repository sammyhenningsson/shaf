class RootController < BaseController

  register_uri :root,    '/'

  get root_uri do
    respond_with nil, serializer: RootSerializer
  end
end
