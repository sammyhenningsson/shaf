require 'shaf/api_doc_task'

Shaf::ApiDocTask.new do |apidoc|
  apidoc.directory = File.join(%w(api serializers))
  apidoc.html_output = "frontend/assets/doc"
  apidoc.yaml_output = "doc/api"
end
