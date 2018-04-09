require 'rake/testtask'

module Shaf
  module Tasks
    class TestTask < Rake::TestTask
      def initialize(*args)
        super(*args) do |t|
          t.libs = %w(. api spec)
          t.verbose = true
          t.warning = false
          yield self if block_given?
        end
      end
    end
  end
end
