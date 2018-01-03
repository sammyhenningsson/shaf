module Serializers
  class Root
    extend HALDecorator
    extend UriHelper

    link :self, root_uri
  end
end

