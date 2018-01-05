require 'fileutils'
require 'shaf/registrable'

module Shaf
  module Generator
    class Registry
      extend Registrable
    end

    class Factory
      def self.create(str, *args)
        clazz = Registry.lookup(str)
        return clazz.new(*args) if clazz
        raise Command::NotFoundError, %Q(Generator '#{str}' is not supported)
      end
    end

    class Base
      attr_reader :args

      class << self
        def inherited(child)
          Registry.register(child)
        end

        def identifier(id)
          @id = id.to_s
        end

        def usage(str)
          @usage = str
        end
      end

      def initialize(*args)
        @args = args.dup
      end
    end

    Dir[File.join(__dir__, 'generator', '*.rb')].each do |file|
      require file
    end
  end
end
