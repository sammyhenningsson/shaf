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
    disable :dump_errors
    set :show_exceptions, :after_handler
  end

  use Rack::Deflater
  register *Shaf.extensions
  helpers *Shaf.helpers

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

  error Shaf::Authorize::PolicyViolationError do
    err = ForbiddenError.new
    respond_with err, status: err.http_status, serializer: Serializers::Error
  end

  error StandardError do
    err = env['sinatra.error']
    err = ServerError.new(err.message) unless err.is_a? ServerError
    respond_with err, status: err.http_status, serializer: Serializers::Error
  end

end
