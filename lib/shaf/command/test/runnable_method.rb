# frozen_string_literal: true

module Shaf
  module Command
    class Test < Base
      class RunnableMethod
        attr_reader :runnable, :name, :line

        def self.from(runnable, method_name)
          _, line = runnable.instance_method(method_name).source_location
          new(runnable, method_name, line)
        end

        def initialize(runnable, name, line)
          @runnable = runnable
          @name = name
          @line = line
        end
      end
    end
  end
end
