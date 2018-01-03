require 'shaf/api_doc_task'

Shaf::ApiDocTask.new do |apidoc|
  apidoc.directory = File.join(%w(app serializers))
  apidoc.html_output = "frontend/assets/html"
  apidoc.text_output = "frontend/assets/text"
end
