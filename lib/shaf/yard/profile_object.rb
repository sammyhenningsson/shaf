# frozen_string_literal: true

module Shaf
  module Yard
    class ProfileObject < ::YARD::CodeObjects::ClassObject
      attr_accessor :profile

      def path
        "Profiles::#{name}"
      end

      def description
        profile&.doc || ""
      end
      
      def profile_name
        name.to_s.sub(/Profile\z/, '')
      end
    end
  end
end
