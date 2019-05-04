class BaseController < Sinatra::Base

  include Shaf::Errors

  configure do
    disable :static
    enable :logging
    enable :method_override
    mime_type :hal, 'application/hal+json'
    set :views, Shaf::Settings.views_folder
    set :static, !production?
    set :public_folder, Shaf::Settings.public_folder
    disable :dump_errors
    set :show_exceptions, :after_handler
    enable :current_user
    set :auth_token_header, Shaf::Settings.auth_token_header
  end

  use Rack::Deflater

  Shaf::Router.mount(self, default: true)

  def self.inherited(controller)
    super
    Shaf::Router.mount controller
  end

  def self.log
    $logger
  end

  def log
    self.class.log
  end

  register(*Shaf.extensions)
  helpers(*Shaf.helpers)

  before do
    log.info "Processing: #{request.request_method} #{request.path_info}"
    log.debug "Payload: #{payload || 'empty'}"
  end

  not_found do
    err = NotFoundError.new "Resource \"#{request.path_info}\" does not exist"
    respond_with(err, status: err.http_status)
  end

  error StandardError do
    err = env['sinatra.error']
    log.error err.message
    Array(err.backtrace).each(&log.method(:error))

    api_error = to_api_error(err)

    respond_with(api_error, status: api_error.http_status)
  end

  def to_api_error(err)
    case err
    when Shaf::Authorize::PolicyViolationError
      ForbiddenError.new
    when ServerError
      err
    when Sequel::ValidationFailed
      Shaf::Errors::ValidationError.from_sequel(err)
    else
      ServerError.new(err.message)
    end
  end
end
