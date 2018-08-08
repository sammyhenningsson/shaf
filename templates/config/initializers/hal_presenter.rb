if [:development, :test].include? Sinatra::Application.settings.environment
  port = Shaf::Settings.port ? ":#{Shaf::Settings.port}" : ""
  HALPresenter.base_href = "http://localhost#{port}"
end

HALPresenter.paginate = true
