require 'rake/testtask'

namespace :test do |ns|
  Rake::TestTask.new(:integration) do |t|
    t.libs = %w(. app spec)
    t.pattern = "spec/integration/**/*_spec.rb"
    t.verbose = true
  end

  Rake::TestTask.new(:models) do |t|
    t.libs = %w(. app spec)
    t.pattern = "spec/models/**/*_spec.rb"
    t.verbose = true
  end

  Rake::TestTask.new(:serializers) do |t|
    t.libs = %w(. app spec)
    t.pattern = "spec/serializers/**/*_spec.rb"
    t.verbose = true
  end

  Rake::TestTask.new(:lib) do |t|
    t.libs = %w(. app spec)
    t.pattern = "spec/lib/**/*_spec.rb"
    t.verbose = true
  end

  Rake::TestTask.new(:all) do |t|
    t.libs = %w(. app spec)
    t.pattern = [
      "spec/lib/**/*_spec.rb",
      "spec/models/**/*_spec.rb",
      "spec/serializers/**/*_spec.rb",
      "spec/integration/**/*_spec.rb"
    ]
    t.verbose = true
  end

end

desc "Run all tests"
task test: 'test:all'

