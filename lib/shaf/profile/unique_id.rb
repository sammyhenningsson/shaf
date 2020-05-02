# frozen_string_literal: true

module Shaf
  class Profile
    module UniqueId
      def id
        return @id if defined? @id
        @id = __find_unique_id
      end

      def __pending_id?
        @__pending_id ||= false
      end

      private

      def __find_unique_id
        @__pending_id = true

        return name.to_s unless __id_collision? name.to_s

        id = [parent.name, name].join('_')
        return id unless __id_collision? id

        id = "#{id}0"

        loop do
          id = id.next
          break id unless __id_collision? id
        end
      ensure
        @__pending_id = false
      end

      def __id_collision? id
        descriptor = self

        loop do
          break false unless descriptor.respond_to?(:parent) && descriptor.parent
          descriptor = descriptor.parent

          __parent_descriptors(descriptor).each do |desc|
            next if desc == self
            next if desc.__pending_id?
            return true if desc.id == id
          end
        end
      end

      def __parent_descriptors(parent)
        descriptors = []
        descriptors += parent.attributes if parent.respond_to? :attributes
        descriptors += parent.relations if parent.respond_to? :relations
        descriptors
      end
    end
  end
end
