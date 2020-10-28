# frozen_string_literal: true

require 'set'
require 'shaf/errors'

module Shaf
  class Initializer
    attr_reader :file

    class NoSuchInitializer < Shaf::Error
      def initialize(file)
        super "Initializer \"#{file}\" does not exist"
      end
    end

    INITIALIZERS_PATH = File.expand_path('../initializers', __FILE__)

    class << self
      def load(file)
        new(file).load
      end

      def load_all
        files.each { |file| Initializer.load(file) }
      end

      private

      def files
        Dir.chdir(INITIALIZERS_PATH) do
          Set['logging.rb'].merge Dir['*.rb']
        end
      end
    end

    def initialize(file)
      file = "#{file}.rb" unless file.end_with? '.rb'
      @file = file
    end

    def content
      Dir.chdir(INITIALIZERS_PATH) do
        raise NoSuchInitializer, file unless ::File.exist? file
        ::File.read(file)
      end
    end

    def load
      name = File.basename(file, '.rb')
      Shaf.log.debug "Loading initializer: #{name}"
      instance_eval content
    end
  end
end

Shaf::Initializer.load_all
