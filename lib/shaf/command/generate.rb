require 'fileutils'
require 'shaf/generator'

module Shaf
  module Command
    class Generate < BaseCommand

      identifier /gen(erate)?/
      usage Generator::Registry.usage

      def call
        Generator::Factory.create(*args).call
      end
    end
  end
end
