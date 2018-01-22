require 'shaf/generator'

module Shaf
  module Command
    class Generate < Base

      identifier %r(gen(erate)?)
      usage Generator::Factory.usage

      def call
        Generator::Factory.create(*args).call
      end
    end
  end
end
