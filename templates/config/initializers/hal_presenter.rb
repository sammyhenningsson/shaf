if Sinatra::Application.settings.environment == :development
  HALPresenter.base_href = 'http://localhost:9292'
end

HALPresenter.paginate = true
