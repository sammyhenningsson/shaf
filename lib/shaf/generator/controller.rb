module Shaf
  module Generator
    class Controller < Base

      identifier :controller
      usage 'generate controller RESOURCE_NAME'

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
