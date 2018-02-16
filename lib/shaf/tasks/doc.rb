require 'shaf/api_doc_task'

Shaf::ApiDocTask.new do |apidoc|
  apidoc.directory = File.join(%w(api serializers))
  apidoc.html_output = File.join(Shaf::Settings.public_folder, "doc")
  apidoc.yaml_output = Shaf::Settings.documents_dir || "doc/api"
end
