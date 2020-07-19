# frozen_string_literal: true

require 'shaf/profile/evaluator'

module Shaf
  class Profile
    class << self
      def inherited(child)
        Profiles.register child
      end

      def name(str = nil)
        @name = str if str
        @name if defined? @name # prevent uninitialized warning
      end

      def match?(str)
        normalize(name) == normalize(str)
      end

      def attributes
        @attributes ||= []
      end

      def relations
        @relations ||= []
      end

      def attribute(*args, **kwargs, &block)
        evaluator.attribute(*args, **kwargs, &block)
      end

      def rel(*args, **kwargs, &block)
        evaluator.rel(*args, **kwargs, &block)
      end

      private

      def evaluator
        Evaluator.new(parent: self)
      end

      def normalize(name)
        name.to_s.downcase.tr('-', '_')
      end
    end
  end
end
