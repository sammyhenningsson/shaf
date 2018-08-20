class RootController < BaseController

  register_uri :root, '/'

  get :root_uri do
    cache_control(:private, http_cache_max_age: :long)
    respond_with nil, serializer: RootSerializer
  end
end
