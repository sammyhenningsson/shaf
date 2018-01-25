require 'irb'

module Shaf
  module Command
    class Console < Base

      identifier :console
      usage 'console'

      def call
        bootstrap
        ARGV.clear
        IRB.start
      end
    end
  end
end
