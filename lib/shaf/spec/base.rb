module Shaf
  module Spec
    class Base < Minitest::Spec
      include Minitest::Hooks
      include PayloadUtils
      include Fixtures::Accessors

      TRANSACTION_OPTIONS = {
        rollback: :always,
        savepoint: true,
        auto_savepoint: true
      }.freeze

      around(:all) do |&block|
        DB.transaction(TRANSACTION_OPTIONS) do
          Shaf::Spec::Fixtures.load(reload: true)
          super(&block)
        end
      end

      around do |&block|
        DB.transaction(TRANSACTION_OPTIONS) { super(&block) }
      end

      before do
        $logger&.info <<~LOG
          \n
          ##########################################################################
          # #{self.class.superclass.name} - #{name}
          ##########################################################################
        LOG
      end
    end
  end
end
