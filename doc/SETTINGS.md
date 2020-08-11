## Settings
Settings are kept in a yaml file found in `$PROJECT_ROOT/config/settings.yml`. When a new project is created it looks like this:
```sh
---
default: &default
  public_folder: frontend/assets
  views_folder: frontend/views
  documents_dir: doc/api
  migrations_dir: db/migrations
  fixtures_dir: spec/fixtures
  paginate_per_page: 25
  http_cache: on
  http_cache_max_age_long: 86400 # 60 * 60 * 24 = 1 day
  http_cache_max_age_short: 3600 #      60 * 60 = 1 hour
  hostname: localhost
  protocol: http
  port: 3000
  auth_token_header: X-Auth-Token
  error_profile_name: shaf-error
  error_profile_uri: https://gist.githubusercontent.com/sammyhenningsson/049d10e2b8978059cde104fc5d6c2d52/raw/shaf-error.md

production:
  <<: *default
  port: <%= ENV.fetch('PORT', 443) %>
  base_uri: https://my.public.shaf.api.com

development:
  <<: *default

test:
  <<: *default
  port: 3030
```
These settings can be read from your code with `Shaf::Settings.NAME_OF_SETTING`. So for example `Shaf::Settings.port` would return 443 in production environment and 3000 in development.
