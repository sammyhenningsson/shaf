require 'shaf'
require 'minitest/autorun'

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
end
