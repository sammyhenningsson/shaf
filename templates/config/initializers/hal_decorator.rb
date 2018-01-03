if Sinatra::Application.settings.environment == :development
  HALDecorator.base_href = 'http://localhost:9292'
end

HALDecorator.paginate = true
