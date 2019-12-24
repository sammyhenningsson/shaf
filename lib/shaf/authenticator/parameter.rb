# frozen_string_literal: true

module Shaf
  module Authenticator
    class Parameter
      attr_reader :name, :default, :values

      def initialize(name, required: true, default: nil, values: nil)
        @name = name
        @required = required
        @default = default
        @values = values&.map(&:downcase)
      end

      def required?
        @required
      end

      def optional?
        !required?
      end

      def valid?(value)
        return optional? if value.nil?
        values.include?(value.downcase)
      end
    end
  end
end
