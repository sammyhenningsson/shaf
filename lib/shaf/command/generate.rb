require 'shaf/generator'

module Shaf
  module Command
    class Generate < Base

      identifier %r(\Ag(en(erate)?)?\Z)
      usage Generator::Factory.usage.flatten.sort

      def self.options(parser, options)
        parser.on("-s", "--[no-]specs", "generate specs") do |s|
          options[:specs] = s
        end

        Generator::Factory.each do |clazz|
          clazz.options(parser, options)
        end
      end

      def call
        in_project_root do
          Generator::Factory.create(*args, **options).call
        end
      rescue StandardError => e
        raise Command::ArgumentError, e.message
      end
    end
  end
end
