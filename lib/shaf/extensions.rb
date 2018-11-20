require 'shaf/extensions/resource_uris'
require 'shaf/extensions/controller_hooks'
require 'shaf/extensions/current_user'
require 'shaf/extensions/authorize'
require 'shaf/extensions/symbolic_routes'

module Shaf
  def self.extensions
    [
      ResourceUris,
      ControllerHooks,
      CurrentUser,
      Authorize,
      SymbolicRoutes
    ]
  end
end
