module Shaf
  module Command
    class Server < Base

      identifier %r(\As(erver)?\Z)
      usage 'server'

      def call
        bootstrap
        App.instance.run!
      end
    end
  end
end

