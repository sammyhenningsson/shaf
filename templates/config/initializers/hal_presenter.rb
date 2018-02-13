if Sinatra::Application.settings.environment == :development
  HALPresenter.base_href = "http://localhost:#{LISTEN_PORT || 3000}"
end

HALPresenter.paginate = true
