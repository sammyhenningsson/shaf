class App
  class << self
    def instance
      unless defined?(@instance)
        @instance = Sinatra.new
        @instance.set :port, Shaf::Settings.port || 3000
      end
      @instance
    end

    def use(middleware)
      instance.use middleware
    end
  end
end
