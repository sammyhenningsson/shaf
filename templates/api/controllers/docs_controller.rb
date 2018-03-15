class DocsController < BaseController

  register_uri :doc_curie,      '/doc/:resource/rels/{rel}'
  register_uri :documentation,  '/doc/:resource'

  get doc_curie_uri_template do
    doc.link(params[:rel])
  end

  get documentation_uri_template do
    doc.to_s
  end

  def doc
    Shaf::DocModel.find!(params[:resource])
  end
end
