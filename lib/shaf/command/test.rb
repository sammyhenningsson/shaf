require 'rubygems'
require 'bundler'
require 'set'
Bundler.require :development, :test
require 'shaf/command/test/filter'
require 'shaf/command/test/runner'
require 'shaf/command/test/runnable_method'

module Shaf
  module Command
    class Test < Base
      identifier %r{\A(t(est)?|spec)\Z}
      usage 'test [FILTER] [..]'

      def call
        disable_autorun

        bootstrap(env: 'test') do
          setup_loadpath
          reporter.start

          spec_files.each do |file|
            lines = lines_to_run(file)
            run(file, lines) if lines
          end

          reporter.report
        end
      end

      private

      def setup_loadpath
        $LOAD_PATH.unshift(spec_dir) unless $LOAD_PATH.include?(spec_dir)
      end

      def disable_autorun
        # This makes sure this at_exit handler is registered after minitest/autorun
        # This will make it run before the at_exit handler in minitest/autorun
        require 'minitest/autorun'
        at_exit do
          exit! reporter.passed?
        end
      end

      def spec_dir
        @spec_dir ||= Settings.spec_dir || 'spec'
      end

      def spec_files
        Dir["#{spec_dir}/**/*.rb"]
      end

      def filters
        @filters ||=
          if args.empty?
            [Filter::None]
          else
            args.map { |arg| Filter.new(arg) }
          end
      end

      def lines_to_run(file)
        lines = filters
          .select { |f| f.match? file }
          .map(&:lines)

        return if lines.empty?
        return [] if lines.any?(&:empty?)
        lines.flatten.to_set
      end

      def run(file, lines = [])
        runners(file, lines).each do |runner|
          runner.call(reporter)
        end
      end

      def reporter
        @reporter ||= Minitest::CompositeReporter.new.tap do |reporter|
          reporter << Minitest::SummaryReporter.new($stdout)
          reporter << Minitest::ProgressReporter.new($stdout)
        end
      end

      def runners(file, lines)
        runnables = runnables_in(file)

        return runnables.map { |r| Runner.new r } if lines.empty?

        methods = methods_for(runnables)

        lines.each_with_object([]) do |line, runners|
          if methods.empty? || line < methods.first.line
            runnables.map { |r| runners << Runner.new(r) }
          else
            spec = methods.partition { |m| m.line < line }.first.last or next
            runners << Runner.new(spec.runnable, spec.name)
          end
        end
      end

      def runnables_in(file)
        require file

        @runnables ||= Set.new

        Minitest::Runnable.runnables.each_with_object([]) do |runnable, loaded|
          next unless runnable.runnable_methods.any?
          next if @runnables.include? runnable
          @runnables << runnable
          loaded << runnable
        end
      end

      def methods_for(runnables)
        methods = []

        runnables.each do |runnable|
          runnable.runnable_methods.each do |name|
            methods << RunnableMethod.from(runnable, name)
          end
        end

        methods.sort_by { |m| m.line }
      end

      def relative_to_root(file)
        file = File.expand_path(file)
        file.sub(File.join(Settings.app_root, ''), '')
      end
    end
  end
end
