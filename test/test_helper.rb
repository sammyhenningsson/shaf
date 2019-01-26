require 'open3'
require 'shaf'
require 'shaf/spec/fixture'
require 'sequel'
require 'bundler'
require 'minitest/autorun'

DB = Sequel.connect('mock://test', database: 'test')

module Minitest
  module Assertions
    def assert_matched_arrays(exp, act)
      exp_ary = exp.to_ary
      act_ary = act.to_ary
      assert_kind_of Array, exp_ary
      assert_kind_of Array, act_ary
      assert_equal exp_ary.sort, act_ary.sort
    end
  end
end

module Shaf
  module Mutable
    def self.suppress_output
      original_stdout, original_stderr = $stdout.clone, $stderr.clone
      $stderr.reopen File.new('/dev/null', 'w')
      $stdout.reopen File.new('/dev/null', 'w')
      yield
    ensure
      $stdout.reopen original_stdout
      $stderr.reopen original_stderr
    end

    def self.capture_output
      original_stdout = $stdout.clone
      $stdout = StringIO.new
      yield
      $stdout.string
    ensure
      $stdout = original_stdout
    end
  end

  module Test
    class << self
      def gem_lib_dir
        File.expand_path('../../lib', __FILE__)
      end

      def bundle_install
        return if ENV['SKIP_BUNDLE_INSTALL']
        Bundler.with_clean_env { `bundle install` }
      end

      def system(*args, stdin: nil)
        return if args.size.zero?
        env = {'RUBYLIB' => gem_lib_dir}
        cmd = args.join(' ')

        Bundler.with_clean_env do
          Open3.popen3(env, cmd) do |std_in, std_out, std_err, wait_thr|
            std_in.write(stdin) && std_in.close unless stdin.nil?
            exit_status = wait_thr.value # Process::Status object returned.
            yield [std_out, std_err].map { |s| s.read.chomp } if block_given?
            exit_status.success?
          end
        end
      end

      def spawn(*args)
        return if args.size.zero?
        env = {'RUBYLIB' => gem_lib_dir}
        Bundler.with_clean_env do
          Kernel::spawn(env, *args)
        end
      end
    end
  end
end
