require 'shaf/extensions/resource_uris'
require 'shaf/extensions/current_user'
require 'shaf/extensions/authorize'

module Shaf
  def self.extensions
    [
      ResourceUris,
      CurrentUser,
      Authorize,
    ]
  end
end
