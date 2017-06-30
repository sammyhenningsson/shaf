if File.exist?  'config/initializers/logging.rb'
  require "config/initializers/logging"
end

Dir.chdir(File.expand_path('initializers', __dir__)) do
  Dir['*.rb'].each do |file|
    lib = File.basename(file, '.rb')
    require "config/initializers/#{lib}" or next
    $logger&.debug "Loading initializer: #{lib}"
  end
end

