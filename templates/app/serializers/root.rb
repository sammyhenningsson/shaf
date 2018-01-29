module Serializers
  class Root
    extend HALPresenter
    extend Shaf::UriHelper

    link :self, root_uri
  end
end

