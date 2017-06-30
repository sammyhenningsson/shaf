module TestUtils
  module Model
    class Request
      attr_reader :env

      def env
        @env ||= {}
      end
    end

    module Test
      def request
        @request ||= Request.new
      end
    end
  end
end
