require 'serializers/base_serializer'

class RootSerializer < BaseSerializer
  link :self, root_uri
end
