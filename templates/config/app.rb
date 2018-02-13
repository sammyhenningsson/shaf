require 'config/constants'

class App
  class << self
    def instance
      unless defined?(@instance)
        @instance = Sinatra.new
        @instance.set :port, LISTEN_PORT
      end
      @instance
    end

    def use(middleware)
      instance.use middleware
    end
  end
end
