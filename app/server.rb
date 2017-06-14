require 'sinatra/base'

class Server < Sinatra::Base
  configure do |c|
    disable :method_override
    disable :static

    set :sessions,
        :httponly     => true,
        :secure       => production?,
        :expire_after => 31557600, # 1 year
        :secret       => ENV['SESSION_SECRET']
  end

  use Rack::Deflater
end

