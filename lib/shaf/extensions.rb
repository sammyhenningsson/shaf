require 'shaf/extensions/resource_uris'
require 'shaf/extensions/authorize'

module Shaf
  def self.extensions
    [
      ResourceUris,
      Authorize,
    ]
  end
end
