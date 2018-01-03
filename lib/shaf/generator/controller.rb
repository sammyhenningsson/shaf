module Shaf
  module Generator
    class Controller < BaseGenerator
      def self.identified_by
        'controller'
      end

      def self.usage
        'generate controller RESOURCE_NAME'
      end

      def call
        @controller_name = args.shift
        puts "generating controller #{@controller_name}.."
        if @controller_name.nil? || @controller_name.empty?
          raise Command::ArgumentError, "Please provide a controller name when using the controller generator!"
        end
      end
    end
  end
end
