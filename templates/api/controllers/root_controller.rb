class RootController < BaseController

  register_uri :root, '/'

  get :root_path do
    cache_control(:private, http_cache_max_age: :long)
    # Uncomment the line below (and change realm if you like) if your api has
    # resources that requires authentication. See
    # https://github.com/sammyhenningsson/shaf/blob/master/doc/AUTHENTICATION.md
    # for more info.
    # www_authenticate realm: 'MyApi'
    
    respond_with nil, serializer: RootSerializer
  end
end
