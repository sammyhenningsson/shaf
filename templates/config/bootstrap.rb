# frozen_string_literal: true

require 'rubygems'
require 'bundler'
Bundler.require(:default, ENV['RACK_ENV'])

$logger = nil
require 'shaf/settings'
require 'config/paths'
require 'config/database'
require 'config/initializers'
require 'config/directories'
require 'config/helpers'
