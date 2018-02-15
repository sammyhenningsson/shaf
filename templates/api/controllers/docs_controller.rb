class DocsController < BaseController

  register_uri :doc_curie,    '/doc/:resource/rels/{rel}'

  get '/doc/:resource/rels/:rel' do
    doc.links(params[:rel])
  end

  get '/doc/:resource' do
    doc.to_s
  end

  def doc
    Shaf::DocModel.find!(params[:resource])
  end
end
