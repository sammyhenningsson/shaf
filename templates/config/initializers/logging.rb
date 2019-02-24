require 'logger'

log_dir = File.join(Shaf::Settings.app_root, 'logs')
Dir.mkdir log_dir unless Dir.exist? log_dir

$logger = Logger.new(File.join(log_dir, "#{Sinatra::Application.settings.environment}.log"))
DB.loggers << $logger
