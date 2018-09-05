class DocsController < BaseController

  register_uri :doc_curie,      '/doc/:resource/rels/{rel}'
  register_uri :documentation,  '/doc/:resource'

  get :doc_curie_uri do
    cache_control(:private, http_cache_max_age: :long)
    doc.link(params[:rel])
  end

  get :documentation_uri do
    cache_control(:private, http_cache_max_age: :long)
    doc.to_s
  end

  def doc
    Shaf::DocModel.find!(params[:resource])
  end
end
