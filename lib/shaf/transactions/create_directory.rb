require 'fileutils'

module Shaf
  module Transactions
    class CreateDirectory < Base
      def initialize(name)
        @name = name
      end
        
      def execute
        dir = name

        until Dir.exist? dir
          directories.unshift dir
          dir = File.dirname dir
        end

        directories.each { |dir| Dir.mkdir dir }
      end

      def undo
        directories.reverse_each { |dir| Dir.unlink dir }
      end

      private

      def directories
        @directories ||= []
      end
    end
  end
end
