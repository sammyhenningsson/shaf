module Serializers
  class Root
    extend HALPresenter
    extend Shaf::UriHelper

    # Auto generated doc:  
    # Link to the root resource. All clients should fetch this resource
    # when starting to interact with this API.  
    # Method: GET  
    # Example:
    # ```
    # curl -H "Accept: application/json" \
    #      -H "Authorization: abcdef" \
    #      /
    #```
    link :self, root_uri
  end
end

