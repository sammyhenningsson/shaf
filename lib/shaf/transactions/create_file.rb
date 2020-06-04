module Shaf
  module Transactions
    class CreateFile < Base
      attr_reader :name, :block

      def initialize(name, &block)
        @name = name
        @block = block
      end

      def before
        dir = File.dirname(name)
        add_before CreateDirectory.new(dir)
      end

      def execute
        block.call
      end

      def undo
        File.unlink name
      end
    end
  end
end
