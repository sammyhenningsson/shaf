require 'shaf/errors'

module Shaf
  module Profiles
    class ProfileNotFoundError < Errors::NotFoundError
      def initialize(name)
        msg = %Q(Profile with name "#{name}" does not exist)
        super(msg, id: name)
      end
    end

    class << self
      def register(clazz)
        profiles << clazz
      end

      def find(name)
        name = String(name)
        return if name.empty?

        profiles.find { |profile| profile.match? name }
      end

      def find!(name)
        find(name) or raise ProfileNotFoundError, name
      end

      def profiles
        @profiles ||= []
      end

      def clear
        @profiles.clear
      end
    end
  end
end

require 'shaf/profile'
require 'shaf/profiles/shaf_form'
require 'shaf/profiles/shaf_error'
require 'shaf/profiles/shaf_basic'
