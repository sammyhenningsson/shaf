class RootController < BaseController

  HTTP_CACHE_MAX_AGE = 86400 # 60 * 60 * 24 = 1 day
  register_uri :root, '/'

  get :root_uri do
    cache_control(:private, max_age: HTTP_CACHE_MAX_AGE) if Shaf::Settings.http_cache
    respond_with nil, serializer: RootSerializer
  end
end
