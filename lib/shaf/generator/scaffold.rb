module Shaf
  module Generator
    class Scaffold < Base

      identifier :scaffold
      usage 'generate scaffold RESOURCE_NAME [attribute:type] [..]'

      def call
        check_name_arg!

        options[:specs] = true if options[:specs].nil? 
        Generator::Factory.create('model', *args, **options).call
        Generator::Factory.create('controller', *args, **options).call
      end

      def check_name_arg!
        return if args.first && !args.first.empty?

        raise Command::ArgumentError,
          "Please provide a name when using the scaffold generator!"
      end
    end
  end
end
