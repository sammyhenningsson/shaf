class DocsController < BaseController

  register_uri :doc_curie,      '/doc/:resource/rels/{rel}'
  register_uri :documentation,  '/doc/:resource'

  before_action do
    cache_control(:private, http_cache_max_age: :long)
  end

  get :doc_curie_path do
    respond_with doc, path: request.path_info, rel: params[:rel]
  end

  get :documentation_path do
    respond_with doc, path: request.path_info
  end

  def doc
    Shaf::ResourceDoc.find!(params[:resource])
  end
end
