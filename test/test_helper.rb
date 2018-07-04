require 'shaf'
require 'minitest/autorun'

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
    def self.gem_lib_dir
      File.expand_path('../../lib', __FILE__)
    end

    def self.system(*args)
      env = {'RUBYLIB' => gem_lib_dir}
      Kernel::system(env, *args)
    end

    def self.spawn(*args)
      env = {'RUBYLIB' => gem_lib_dir}
      Kernel::spawn(env, *args)
    end
  end
end
