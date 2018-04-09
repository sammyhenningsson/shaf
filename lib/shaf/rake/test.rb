require 'shaf/tasks'

namespace :test do |ns|
  Shaf::TestTask.new(:integration) do |t|
    t.pattern = "spec/integration/**/*_spec.rb"
  end

  Shaf::TestTask.new(:models) do |t|
    t.pattern = "spec/models/**/*_spec.rb"
  end

  Shaf::TestTask.new(:serializers) do |t|
    t.pattern = "spec/serializers/**/*_spec.rb"
  end

  Shaf::TestTask.new(:lib) do |t|
    t.pattern = "spec/lib/**/*_spec.rb"
  end

  Shaf::TestTask.new(:all) do |t|
    t.pattern = [
      "spec/lib/**/*_spec.rb",
      "spec/models/**/*_spec.rb",
      "spec/serializers/**/*_spec.rb",
      "spec/integration/**/*_spec.rb"
    ]
  end
end

desc "Run all tests"
task test: 'test:all'

