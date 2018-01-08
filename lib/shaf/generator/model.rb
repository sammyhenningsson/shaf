module Shaf
  module Generator
    class Model < Base

      identifier :model
      usage 'generate model MODEL_NAME'

      def call
        @model_name = args.shift
        puts "generating model #{@model_name}.."
        if @model_name.nil? || @model_name.empty?
          raise Command::ArgumentError, "Please provide a model name when using the model generator!"
        end

        create_migration
        Generator::Factory.create('migration', "create #{@model_name} table").call
      end
    end
  end
end
