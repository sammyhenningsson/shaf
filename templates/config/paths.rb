# frozen_string_literal: true

app_root = File.expand_path('../', __dir__)
[
  Shaf::Settings.app_root = app_root,
  Shaf::Settings.app_dir = File.expand_path('api', app_root),
  Shaf::Settings.src_dir = File.expand_path('src', app_root),
  Shaf::Settings.lib_dir = File.expand_path('lib', app_root),
  Shaf::Settings.spec_dir = File.expand_path('spec', app_root)
].each do |dir|
  $LOAD_PATH.unshift(dir) if Dir.exist? dir
end
