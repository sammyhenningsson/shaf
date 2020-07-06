module Shaf
  module Yard
    class SerializerHandler < ::YARD::Handlers::Ruby::Base
      handles :class

      process do
        next unless serializer?

        register object
      end

      def name
        statement[0].source
      end

      def serializer?
        name.match? %r{Serializer$}
      end

      def object
        ResourceObject.new(namespace, name).tap do |obj|
          obj.dynamic = true
        end
      end
    end
  end
end
