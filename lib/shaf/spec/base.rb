module Shaf
  module Spec
    class Base < Minitest::Spec
      include Minitest::Hooks
      include PayloadUtils
      include Fixtures

      TRANSACTION_OPTIONS = {
        rollback: :always,
        savepoint: true,
        auto_savepoint: true
      }.freeze

      around(:all) do |&block|
        DB.transaction(TRANSACTION_OPTIONS) do
          Shaf::Spec::Fixtures.load
          super(&block)
        end
      end

      around do |&block|
        DB.transaction(TRANSACTION_OPTIONS) { super(&block) }
      end
    end
  end
end
