module Routes
  class BaseRoute < Sinatra::Base
    def self.inherited(child)
      ::Server.use child
      super
    end
  end

  def self.setup
    dir = File.dirname(__FILE__)
    Dir[File.join(dir, 'routes', '**', '*.rb')].each do |file|
      require file
    end
  end

  setup

end
