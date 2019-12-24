require 'sinatra/base'

module Shaf
  module Authorize
    class NoPolicyError < Error; end
    class PolicyViolationError < Error; end
    class MissingPolicyAction < Error; end

    attr_reader :policy_class

    def self.registered(app)
      app.helpers Helpers
    end

    def authorize_with(policy_class)
      @policy_class = policy_class
    end
  end

  module Helpers
    def authorize(action, resource = nil)
      policy = policy(resource)
      raise Authorize::NoPolicyError unless policy

      method = __method_for(action)
      return policy.public_send(method) if policy.respond_to? method

      raise Authorize::MissingPolicyAction,
        "#{policy.class} does not implement method #{method}"
    end

    def authorize!(action, resource = nil)
      authorize(action, resource) or raise Authorize::PolicyViolationError
    end

    private

    def policy(resource)
      user = current_user if respond_to? :current_user
      self.class.policy_class&.new(user, resource)
    end

    def __method_for(action)
      return action if action.to_s.end_with? '?'
      :"#{action}?"
    end
  end
end
