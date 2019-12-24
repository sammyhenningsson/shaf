require 'shaf/authenticator/challenge'
require 'shaf/authenticator/parameter'


module Shaf
  module Authenticator
    class Base
      class MissingParametersError < Error
        def initialize(authenticator, *args)
          super("Missing required parameters: [#{args.join(', ')}] for #{authenticator}")
        end
      end

      class InvalidParametersError < Error
        def initialize(authenticator, *args)
          str = args.map { |key, value| "#{key}: #{value}" }.join(', ')
          super("Invalid parameters for #{authenticator}: #{str}")
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
          return challenges if realm.nil?

          challenges.select do |challenge|
            challenge.realm? realm
          end
        end

        def user(request, realm: nil)
          auth = authorization(request)
          cred = credentials(auth, request)
          return unless cred

          challenges_for(realm).each do |challenge|
            user = challenge.test(*cred)
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
          errors = required_params.each_with_object([]) do |param, errors|
            next if parameters.key? param.name
            next if param.default
            errors << param.name
          end
          raise MissingParametersError.new(self, *errors) unless errors.empty?

          errors = parameters.each_with_object([]) do |(key, value), errors|
            if params.key? key
              errors << [key, value] unless params[key].valid? value
            else
              logger = $logger || Logger.new(STDERR)
              logger.warn "Unsupported authenticator parameter " \
                          "for #{self} -> #{key} = \"#{value}\""
              parameters.delete(key)
            end
          end
          raise InvalidParametersError.new(self, *errors) unless errors.empty?
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
          request.authorization&.delete_prefix "#{scheme} "
        end
      end
    end
  end
end

