# frozen_string_literal: true
module Shaf
  module Command
    class Test < Base
      class Runner
        attr_reader :runnable, :method_name

        def initialize(runnable, method_name = nil)
          @runnable = runnable
          @method_name = method_name
        end

        def call(reporter)
          runnable.run(reporter, options)
        end

        def options
          return {} unless method_name

          {filter: method_name}
        end
      end
    end
  end
end
