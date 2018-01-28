module Serializers
  class Root
    extend HALPresenter
    extend UriHelper

    link :self, root_uri
  end
end

