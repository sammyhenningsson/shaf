require 'shaf/registrable_factory'

module Shaf
  module Command
    class CommandError < StandardError; end

    class Factory
      extend RegistrableFactory
    end
  end
end

require 'shaf/command/base'
require 'shaf/command/console'
require 'shaf/command/generate'
require 'shaf/command/new'
require 'shaf/command/server'
require 'shaf/command/test'
require 'shaf/command/upgrade'
require 'shaf/command/version'
