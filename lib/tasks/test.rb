require 'rake/testtask'

namespace :test do |ns|
  Rake::TestTask.new(:integration) do |t|
    t.libs = %w(. app test)
    t.pattern = "test/integration/**/*_test.rb"
    t.verbose = true
  end

  Rake::TestTask.new(:models) do |t|
    t.libs = %w(. app test)
    t.pattern = "test/model/**/*_test.rb"
    t.verbose = true
  end

  Rake::TestTask.new(:serializers) do |t|
    t.libs = %w(. app test)
    t.pattern = "test/serializer/**/*_test.rb"
    t.verbose = true
  end

  Rake::TestTask.new(:lib) do |t|
    t.libs = %w(. app test)
    t.pattern = "test/lib/**/*_test.rb"
    t.verbose = true
  end

  Rake::TestTask.new(:all) do |t|
    t.libs = %w(. app test)
    t.pattern = [
      "test/lib/**/*_test.rb",
      "test/model/**/*_test.rb",
      "test/serializer/**/*_test.rb",
      "test/integration/**/*_test.rb"
    ]
    t.verbose = true
  end

end

desc "Run all tests"
task test: 'test:all'

