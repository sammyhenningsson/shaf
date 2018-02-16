require 'rubygems'
require 'bundler'
Bundler.require(:default, ENV['RACK_ENV'])

$logger = nil
require 'shaf/settings'
require 'config/constants'
require 'config/database'
require 'config/initializers'
require 'config/app'
require 'api/controllers/base_controller'
require 'config/directories'
require 'config/helpers'
