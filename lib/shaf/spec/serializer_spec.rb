# frozen_string_literal: true

module Shaf
  module Spec
    class SerializerSpec < Base
      include PayloadUtils

      register_spec_type self do |desc, args|
        next true if desc.to_s =~ /Serializer$/
        next unless args && args.is_a?(Hash)
        args[:type]&.to_s == 'serializer'
      end

      def serialize(resource, current_user:)
        set_payload HALPresenter.to_hal(resource, current_user: current_user)
      end
    end
  end
end
