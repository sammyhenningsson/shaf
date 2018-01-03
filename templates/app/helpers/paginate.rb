module Paginate

  def current_page
    page = (params[:page] || 1).to_i
    page == 0 ? 1 : page
  end

  def paginate!(collection, per_page = PAGINATION_PER_PAGE)
    unless collection.respond_to? :paginate
      log.warning "Trying to paginate a collection that doesn't " \
                  "support pagination: #{collection}"
      return
    end

    per_page = params[:per_page].to_i if params[:per_page]
    collection.paginate(current_page, per_page)
  end

  def paginate(collection, per_page = PAGINATION_PER_PAGE)
    paginate!(collection.dup, per_page)
  end
end
