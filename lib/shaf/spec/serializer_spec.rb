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
        next true if desc =~ /Serializer$/
        next unless args && args.is_a?(Hash)
        args[:type]&.to_s == 'serializer'
      end

      around do |&block|
        DB.transaction(TRANSACTION_OPTIONS) { super(&block) }
      end
    end
  end
end
