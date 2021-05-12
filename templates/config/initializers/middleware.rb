require 'shaf/middleware/request_id'
require 'shaf/router'

Shaf::App.use Rack::Deflater
Shaf::App.use Shaf::Middleware::RequestId
Shaf::App.use Shaf::Router
