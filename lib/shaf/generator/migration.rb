module Shaf
  module Generator
    module Migration

      class Factory
        extend RegistrableFactory
      end

      class Generator < Shaf::Generator::Base
        identifier :migration
        usage { Factory.usage }

        def call
          generator = 
            if Factory.lookup(*args)
              Factory.create(*args, **options)
            else
              Empty.new(*args, **options)
            end
          (target, content) = generator.call
          write_output(target, content)
        rescue StandardError => e
          raise Command::ArgumentError, e.message
        end
      end
    end
  end
end

require 'shaf/generator/migration/base'
require 'shaf/generator/migration/add_column'
require 'shaf/generator/migration/add_index'
require 'shaf/generator/migration/create_table'
require 'shaf/generator/migration/drop_column'
require 'shaf/generator/migration/empty'
require 'shaf/generator/migration/rename_column'
