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

      def serialize(resource, current_user: nil)
        serializer = __serializer || HALPresenter
        set_payload serializer.to_hal(resource, current_user: current_user)
      end

      private

      def __serializer
        serializer = self.class.ancestors.find do |klass|
          desc = klass.desc if klass.respond_to? :desc
          break desc if desc&.to_s&.end_with? "Serializer"
        end
        Class === serializer ? serializer : Kernel.const_get(serializer.to_s)
      end
    end
  end
end
