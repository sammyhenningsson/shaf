APP_ROOT = File.expand_path('../', __dir__)
APP_DIR = File.expand_path('api', APP_ROOT)
SRC_DIR = File.expand_path('src', APP_ROOT)
VIEWS_DIR = File.join(APP_ROOT, Shaf::Settings.views_folder)
ASSETS_DIR = File.join(APP_ROOT, Shaf::Settings.public_folder)
PAGINATION_PER_PAGE = Shaf::Settings.paginate_per_page || 25
