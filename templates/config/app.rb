class App
  class << self
    def instance
      @instance ||= Sinatra.new
    end

    def use(middleware)
      instance.use middleware
    end
  end
end
