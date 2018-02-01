class BaseController < Sinatra::Base

  include Shaf::Errors

  configure do
    disable :static
    enable :logging
    enable :method_override
    mime_type :hal, 'application/hal+json'
    set :views, VIEWS_DIR
    set :static, !production?
    set :public_folder, ASSETS_DIR
    enable :dump_errors
    set :show_exceptions, :after_handler
  end

  use Rack::Deflater
  register Shaf::ResourceUris
  helpers Shaf::Payload, Shaf::JsonHtml, Shaf::Paginate, Shaf::Session

  def self.inherited(controller)
    super
    App.use controller
  end


  def log
    $logger
  end

  before do
    log.info "Processing: #{request.request_method} #{request.path_info}"
    log.debug "Payload: #{payload || 'empty'}"
  end

  error StandardError do
    err = env['sinatra.error']
    err = ServerError.new(err.message) unless err.is_a? ServerError
    respond_with err, status: err.http_status, serializer: Serializers::Error
  end

end
