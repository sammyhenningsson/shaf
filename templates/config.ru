$:.unshift __dir__
require 'config/bootstrap'

run Shaf::App.instance
