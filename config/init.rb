require 'sinatra'
require 'sinatra/config_file'

env = Sinatra::Application.settings.environment

config = File.join(File.dirname(__FILE__), "#{env}.yml")
Sinatra::Application.config_file(config)

Bundler.require(:default, env)
