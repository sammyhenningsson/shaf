module Shaf
  module Generator
    class Scaffold < Base

      identifier :scaffold
      usage 'generate scaffold RESOURCE_NAME [attribute:type] [..]'

      def call
        if name.empty?
          raise "Please provide a resource name when using the scaffold generator!"
        end

        Generator::Factory.create('model', *args).call
        Generator::Factory.create('controller', name).call
      end

      def name
        args.first || ""
      end
    end
  end
end
