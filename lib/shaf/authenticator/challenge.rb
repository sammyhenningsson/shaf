# frozen_string_literal: true

module Shaf
  module Authenticator
    class Challenge
      attr_reader :scheme, :parameters, :realm

      def initialize(scheme, **parameters, &block)
        @scheme = scheme
        @realm = parameters.delete(:realm)&.to_s
        @parameters = parameters
        define_singleton_method(:test, &block)
      end

      def to_s
        "#{scheme} #{parameter_string}"
      end

      def realm?(arg)
        realm&.to_s == arg&.to_s
      end

      private

      def parameter_string
        params = {}
        params[:realm] = realm if realm
        params.merge(parameters).map { |k,v| %Q(#{k}="#{v}") }.join(', ')
      end
    end
  end
end
