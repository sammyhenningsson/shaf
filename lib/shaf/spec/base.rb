module Shaf
  module Spec
    class Base < Minitest::Spec
      include Minitest::Hooks
      include Fixtures::Accessors
      include UriHelper
      include LetBang

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
        Shaf.log.info <<~LOG
          \n
          ##########################################################################
          # #{self.class.superclass.name} - #{name}
          ##########################################################################
        LOG

        let_bangs.each { |name| send(name) }
      end
    end
  end
end
