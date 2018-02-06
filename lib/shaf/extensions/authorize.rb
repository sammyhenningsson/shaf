require 'sinatra/base'

module Shaf

  module Authorize
    class NoPolicyError < StandardError; end
    class PolicyViolationError < StandardError; end

    attr_reader :policy_class

    def authorize_with(policy_class)
      @policy_class = policy_class
    end

    def self.registered(app)
      app.helpers Helpers
    end
  end

  module Helpers
    def policy(resource)
      return @policy if @policy
      user = current_user if respond_to? :current_user
      @policy = self.class.policy_class&.new(user, resource)
    end

    def authorize(action, resource = nil)
      policy(resource) or raise Authorize::NoPolicyError
      @policy.public_send method_for(action)
    end

    def authorize!(action, resource = nil)
      authorize(action, resource) or raise Authorize::PolicyViolationError
    end

    def method_for(action)
      return action if action.to_s.end_with? '?'
      "#{action}?".to_sym
    end
  end

end
