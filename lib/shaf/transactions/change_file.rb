require 'fileutils'

module Shaf
  module Transactions
    class ChangeFile < Base
      attr_reader :name, :block

      def initialize(name, &block)
        @name = name
        @block = block
      end

      def before
        add_before(
          CreateFile.new(tmp_name) { FileUtils.copy name, tmp_name }
        )
      end

      def execute
        block.call
      end

      def undo
        FileUtils.copy tmp_name, name
      end

      private

      def tmp_name
        dir = '/tmp/shaf_transations' # FIXME: tmpdir
        File.join(dir, name)
      end
    end
  end
end
