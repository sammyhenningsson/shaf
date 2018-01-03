module Shaf
  module Generator
    class Scaffold < BaseGenerator
      def self.identified_by
        'scaffold'
      end

      def self.usage
        'generate scaffold RESOURCE_NAME'
      end

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
