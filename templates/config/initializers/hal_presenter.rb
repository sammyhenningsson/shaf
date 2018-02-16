if Sinatra::Application.settings.environment == :development
  port = Shaf::Settings.port ? ":#{Shaf::Settings.port}" : ""
  HALPresenter.base_href = "http://localhost#{port}"
end

HALPresenter.paginate = true
