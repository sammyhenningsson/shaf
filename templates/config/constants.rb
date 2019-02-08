APP_ROOT = File.expand_path('../', __dir__)
APP_DIR = File.expand_path('api', APP_ROOT)
SRC_DIR = File.expand_path('src', APP_ROOT)
LIB_DIR = File.expand_path('lib', APP_ROOT)
VIEWS_DIR = File.join(APP_ROOT, Shaf::Settings.views_folder)
ASSETS_DIR = File.join(APP_ROOT, Shaf::Settings.public_folder)
AUTH_TOKEN_HEADER = 'HTTP_X_AUTH_TOKEN'
PAGINATION_PER_PAGE = Shaf::Settings.paginate_per_page || 25
