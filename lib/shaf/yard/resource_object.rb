module Shaf
  module Yard
    class ResourceObject < ::YARD::CodeObjects::ClassObject
      attr_accessor :profile

      def self.path(*args, sep: '::')
        ['Serializers', *args].join(sep)
      end

      def path
        self.class.path(super, sep: sep)
      end

      def attributes
        children.select { |child| child.type == :attribute }
      end

      def links
        children.select { |child| child.type == :link }
      end

      def resource_name
        name.to_s.sub(/_?serializer$/i, '').capitalize
      end

      def profile?
        !!profile
      end

      def profile_name
        return '' unless profile?

        profile.name
      end
    end
  end
end
