require 'shaf/authenticator/challenge'
require 'shaf/authenticator/parameter'
require 'shaf/errors'

module Shaf
  module Authenticator
    class Base
      class MissingParametersError < Error
        def initialize(authenticator, *args)
          super("Missing required parameters: [#{args.join(', ')}] for #{authenticator}")
        end
      end

      class InvalidParameterError < Error
        def initialize(authenticator, *args)
          str = args.map { |key, value| "#{key}: #{value}" }.join(', ')
          super("Invalid parameters for #{authenticator}: #{str}")
        end
      end

      class WrongCredentialsReturnTypeError < Error
        def initialize(authenticator, clazz)
          super <<~ERR
            #{authenticator}.credentials return an instance of #{clazz}
              It must return an instance of Hash.
              Location: #{authenticator.method(:credentials).source_location})
          ERR
        end
      end

      class << self
        def inherited(child)
          Authenticator.register(child)
        end

        def scheme(scheme = nil)
          if scheme
            @scheme = scheme.to_s
          elsif @scheme
            @scheme
          else
            raise Error, "#{self} must specify a scheme!"
          end
        end

        def scheme?(str)
          return false unless scheme

          str.to_s.downcase == scheme.downcase
        end

        def param(name, required: true, default: nil, values: nil)
          params[name.to_sym] = Parameter.new(
            name,
            required: required,
            default: default,
            values: values
          )
        end

        def restricted(**parameters, &block)
          validate! parameters
          add_defaults! parameters
          challenges << Challenge.new(scheme, **parameters, &block)
        end

        def challenges_for(realm)
          challenges.select do |challenge|
            challenge.realm? realm
          end
        end

        def user(request, realm: nil)
          auth = authorization(request)
          cred = credentials(auth, request) || {}
          raise WrongCredentialsReturnTypeError.new(self, cred.class) unless cred.kind_of? Hash

          return if cred.compact.empty?

          challenges_for(realm).each do |challenge|
            user = challenge.test(**cred)
            return user if user
          end

          nil
        end

        def params
          @params ||= superclass.respond_to?(:params) ? superclass.params.dup : {}
        end

        protected

        # Subclasses should implement this method. The return value should be and array
        # that will get passed as block arguments to the block passed to #restricted
        def credentials(authorization, request); end

        private

        def challenges
          @challenges ||= []
        end

        def validate!(parameters)
          validate_required(parameters)
          validate_params(parameters)
        end

        def validate_required(parameters)
          errors = []

          required_params.each do |param|
            next if parameters.key? param.name
            next if param.default
            errors << param.name
          end

          raise MissingParametersError.new(self, *errors) unless errors.empty?
        end

        def validate_params(parameters)
          errors = []

          parameters.each do |key, value|
            if params.key? key
              errors << [key, value] unless params[key].valid? value
            else
              logger.warn "Unsupported authenticator parameter " \
                          "for #{self}: #{key} = \"#{value}\""
              parameters.delete(key)
            end
          end

          raise InvalidParameterError.new(self, *errors) unless errors.empty?
        end

        def logger
          Shaf.logger
        end

        def add_defaults!(parameters)
          params.each do |key, param|
            next unless param.default
            parameters[key] ||= param.default
          end
        end

        def required_params
          params.values.select(&:required?)
        end

        def authorization(request)
          return unless request.authorization

          request.authorization.sub(/^#{scheme} /i, '')
        end
      end
    end
  end
end

