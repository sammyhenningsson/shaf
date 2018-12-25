module Shaf
  module Generator
    class Scaffold < Base

      identifier :scaffold
      usage 'generate scaffold RESOURCE_NAME [attribute:type] [..]'

      def call
        if name.empty?
          raise "Please provide a resource name when using the scaffold generator!"
        end

        options[:specs] = true if options[:specs].nil? 
        Generator::Factory.create('model', *args, **options).call
        Generator::Factory.create('controller', *controller_args, **options).call
      end

      def name
        args.first || ""
      end

      def controller_args
        [name] + args[1..-1]
      end
    end
  end
end
