require 'logger'

module Shaf
  module Log
    def self.registered(app)
      app.helpers Helpers
    end

    def log
      $logger ||= Logger.new('/dev/nul')
    end
  end

  module Helpers
    def log
      self.class.log
    end
  end
end
