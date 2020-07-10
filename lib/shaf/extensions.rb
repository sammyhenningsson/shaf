require 'shaf/extensions/log'
require 'shaf/extensions/resource_uris'
require 'shaf/extensions/controller_hooks'
require 'shaf/extensions/authorize'
require 'shaf/extensions/symbolic_routes'
require 'shaf/extensions/api_routes'

module Shaf
  def self.extensions
    [
      Log,
      ResourceUris,
      ControllerHooks,
      Authorize,
      SymbolicRoutes,
      ApiRoutes # This extension must be registered after `SymbolicRoutes`!
    ]
  end
end
