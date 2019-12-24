require 'shaf/extensions/log'
require 'shaf/extensions/resource_uris'
require 'shaf/extensions/controller_hooks'
require 'shaf/extensions/authorize'
require 'shaf/extensions/symbolic_routes'

module Shaf
  def self.extensions
    [
      Log,
      ResourceUris,
      ControllerHooks,
      Authorize,
      SymbolicRoutes
    ]
  end
end
