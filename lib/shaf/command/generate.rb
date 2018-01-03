require 'fileutils'
require 'byebug'

module Shaf
  module Command
    class Generate < BaseCommand
      def self.identified_by
        'generate'
      end
      
      def self.usage
        'generate [scaffold|resource|migration|controller] NAME'
      end

      def call
        puts "Not implemented yet"
      end

    end
  end
end
