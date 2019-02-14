require 'rubygems'
require 'bundler'
Bundler.setup(:default, :development)
$:.unshift __dir__
require 'shaf/rake'
require 'shaf/settings'

Shaf::ApiDocTask.new do |api_doc|
  api_doc.source_dir = File.join(%w(api serializers))
  api_doc.html_output_dir = File.join(Shaf::Settings.public_folder, "doc")
  api_doc.yaml_output_dir = Shaf::Settings.documents_dir || "doc/api"
end

namespace :test do
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
