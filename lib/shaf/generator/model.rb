module Shaf
  module Generator
    class Model < BaseGenerator

      identifier :model
      usage 'generate model MODEL_NAME'

      def call
        @model_name = args.shift
        puts "generating model #{@model_name}.."
        if @model_name.nil? || @model_name.empty?
          raise Command::ArgumentError, "Please provide a model name when using the model generator!"
        end
      end
    end
  end
end
