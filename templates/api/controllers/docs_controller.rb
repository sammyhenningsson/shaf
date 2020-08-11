class DocsController < BaseController

  register_uri :profile,        '/doc/profiles/:name'
  register_uri :doc_curie,      '/doc/profiles/:name{#rel}'
  register_uri :documentation,  '/doc/:resource'

  before_action do
    cache_control(:private, http_cache_max_age: :long)
  end

  # Note: This route handles both :profile_path and :doc_curie_path
  get :profile_path do
    respond_with Shaf::Profiles.find!(params[:name])
  end

  get :documentation_path do
    respond_with doc, path: request.path_info
  end

  def doc
    Shaf::ResourceDoc.find!(params[:resource])
  end
end
