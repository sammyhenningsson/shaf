require 'fileutils'
require 'shaf/generator'

module Shaf
  module Command
    class Generate < BaseCommand
      def self.identified_by
        'generate'
      end
      
      def self.usage
        Generator::Registry.usage
      end

      def call
        Generator::Factory.create(*args).call
      end
    end
  end
end
