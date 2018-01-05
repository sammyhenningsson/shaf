module Shaf
  module Generator
    class Scaffold < BaseGenerator

      identifier :scaffold
      usage 'generate scaffold RESOURCE_NAME'

      def call
        name = args.shift
        puts "generating scaffold #{name}.."
        if name.nil? || name.empty?
          raise Command::ArgumentError, "Please provide a resource name when using scaffold generator!"
        end
        Generator::Factory.create('model', name, *args).call
        Generator::Factory.create('controller', name, *args).call
      end
    end
  end
end
