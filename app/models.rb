module Models

  def self.setup
    dir = File.dirname(__FILE__)
    #$LOAD_PATH << File.expand_path('.', File.join(dir, 'models'))
    Dir[File.join(dir, 'models', '**', '*.rb')].each do |file|
      require file
    end
  end

  setup

end

