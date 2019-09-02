# frozen_string_literal: true

$logger = nil

require 'shaf'
if ENV['RACK_ENV'] == 'test'
  require 'minitest'
  require 'minitest/autorun'
  require 'minitest/hooks'
  require 'shaf/spec'
end

require 'config/paths'
require 'config/database'
require 'config/initializers'
require 'config/directories'
require 'config/helpers'
