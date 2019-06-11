# frozen_string_literal: true

module Shaf
  module Command
    class Test < Base
      class Filter
        attr_reader :pattern, :lines

        def initialize(criteria)
          pattern, *lines = criteria.split(':')
          @lines = lines.map(&:to_i)
          @pattern = Regexp.new(pattern)
        end

        def match?(file)
          pattern.match? file
        end
      end

      Filter::None = Filter.new('.*.rb')
    end
  end
end
