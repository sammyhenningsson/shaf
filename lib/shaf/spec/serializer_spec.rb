module Shaf
  module Spec
    class SerializerSpec < Minitest::Spec
      include Minitest::Hooks
      include PayloadUtils

      TRANSACTION_OPTIONS = {
        rollback: :always,
        savepoint: true,
        auto_savepoint: true
      }.freeze

      register_spec_type self do |desc, args|
        return true if desc =~ /Serializer$/
        return unless args && args.is_a?(Hash)
        args[:type]&.to_s == 'serializer'
      end

      around do |&block|
        DB.transaction(TRANSACTION_OPTIONS) { super(&block) }
      end
    end
  end
end
