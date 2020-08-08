require 'shaf/registrable_factory'

module Shaf
  module Generator
    class Factory
      extend RegistrableFactory
    end
  end
end

require 'shaf/generator/base'
require 'shaf/generator/controller'
require 'shaf/generator/doc'
require 'shaf/generator/forms'
require 'shaf/generator/migration'
require 'shaf/generator/model'
require 'shaf/generator/policy'
require 'shaf/generator/scaffold'
require 'shaf/generator/serializer'
require 'shaf/generator/profile'
