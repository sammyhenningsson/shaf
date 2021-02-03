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
        File.expand_path('../lib', __dir__)
      end

      def gem_path
        File.expand_path('..', __dir__)
      end

      def shaf_cmd
        File.join(gem_path, 'bin/shaf')
      end

      def patch_gemfile_shaf_path(gemfile_dir = '.')
        Dir.chdir(gemfile_dir) do
          gemfile = File.read 'Gemfile'
          gemfile.sub!(/gem 'shaf'/, "\\0, path: '#{gem_path}'")
          File.write('Gemfile', gemfile)
        end
      end

      def bundle_install
        return if ENV['SKIP_BUNDLE_INSTALL']
        Bundler.with_unbundled_env { `bundle install` }
      end

      def exec_shaf(cmd, stdin: nil, rack_env: 'development', &block)
        system(
          "bundle exec #{shaf_cmd} #{cmd}",
          stdin: stdin,
          rack_env: rack_env,
          &block
        )
      end

      def system(*args, stdin: nil, rack_env: 'development', &block)
        return if args.size.zero?
        env = {'RUBYLIB' => gem_lib_dir, 'RACK_ENV' => rack_env}
        cmd = args.join(' ')

        Bundler.with_unbundled_env do
          Open3.popen3(env, cmd) do |std_in, std_out, std_err, wait_thr|
            std_in.write(stdin) && std_in.close unless stdin.nil?
            exit_status = wait_thr.value # Process::Status object returned.
            if block_given?
              yield [std_out, std_err].map { |s| s.read.chomp }
            elsif !exit_status.success? && ENV['VERBOSE'].to_i == 1
              [[std_out, "Output"], [std_err, "Error"]].each do |fd, prefix|
                output = fd.read.chomp
                STDERR.puts "\n#{prefix}: #{output}\n" unless output.empty?
              end
            end
            exit_status.success?
          end
        end
      end

      def spawn(*args, redirects: {}, rack_env: 'development')
        return if args.size.zero?
        env = {'RUBYLIB' => gem_lib_dir, 'RACK_ENV' => rack_env}
        Bundler.with_unbundled_env do
          Kernel::spawn(env, *args, redirects)
        end
      end
    end
  end
end
