## 2.0.0
 * New framework for parsing input
 * New framework for authentication
 * Mediatype profiles
 * API documentation using yard
 * Improved routes rake task
 * Shaf.log instead of global variable
 * Allow routes to be declared without …_path
 * \_collection uri helper
 * Fixes for Ruby 3.0 keyword args
 * profile helper for serializers
 * Default to application/problem+json for errors
 * Wrap non-HAL responses in HTML
 * Use shaf form profile from lib instead of gist
 * Use shaf error profile from lib instead of gist
 * Curie links point to profile with fragment id
 * Serialize profils with ALPS
 * Project name in settings.yml
 * Load initializers in their own contexts
 * Module methods for adding uri helpers
 * Use FileTransactions in upgrades
 * Use FileTransactions in generators
 * Remove X-Auth-Token header usage
 * Vary helper
## 1.6.1
 * Fix bug when reading input from Rack
 * Minor fix in config.ru
## 1.6.0
 * Add HTTP headers to html view
 * Add some css styling
## 1.5.2
 * Fix problem with missing patches during upgrade
## 1.5.1
 * Fix preloading problem for collections
## 1.5.0
 * Link preloading
 * Fix problem leading to sinatra html error responses
## 1.4.1
 * Test ruby 2.7 in CI
 * Fix ruby 2.7 warnings
 * Gem test speed up
## 1.4.0
 * Replace Net::HTTP with Faraday in tests
 * Support application/problem+json
 * Added Responder classes
 * Respond with 405 when http method is not allowed
## 1.3.0
 * Render api ocumentation as HAL
 * Fix errors rendering documentation
 * Fixed some previous bad upgrade packages
 * Continue upgrade from correct version
 * Remove doc curie from rels already in IANA
## 1.2.2
 * Fix bug with broken settings for ruby 2.5
 * Removed failing settings patch from 1.2.1 upgrade pkg
## 1.2.1
 * Add base_uri config to fix port problem in prodction
 * Fix path issue when using thin -R config.ru start
## 1.2.0
 * Wrap spec expectations with \_(…)
 * Run erb on configs
 * Move database config into yaml
 * Refactored db migrations initializer
 * Add auth token header to Vary
 * Show rel 'collection' instead of 'up' for items
 * Fix problem with generating doc for links
 * Break if package cannot be applied
 * Add option to skip a version during upgrade
 * Add missing patches to previous upgrade pkgs
 * Ignore .rej and .orig files during upgrades
 * Fix problems with loadpath when not using bundle exec
 * Add possiblity to run upgrade until specified version
 * Env VERBOSE=1 will print some more info during upgrade
## 1.1.0
 * Min required ruby version 2.5
 * Get media type profile from serializer
 * Moved forms instead separate class
 * Add a command to run specs
 * Specify override values when filling in form in specs
## 1.0.4
 * Catch Sequel validation errors
## 1.0.3
 * Fix bad form type for foreign keys
 * Fix incorrect Cache-Control Header
 * Add Sequel validation helpers
## 1.0.0
 * Min required ruby version 2.4
 * Continue upgrading when patch is rejected
 * Add a router to select the right controller
 * Add a serializer for validation errors
 * Set curie for _up_ links
 * Add support for media profiles
 * Add helper to read HTTP Headers
 * Move global constants into settings
 * Method to convert Sequel::ValidationFailed error
 * Moved test tasks into Rakefile
 * Add optional name to empty migration generator
 * Add an error class for validation errors
 * Fix bug with lookup of error classes
 * Symbolize keys in request payload
 * Set Content-Type to application/json in integration specs
 * Add #blank? to all objects (Sequel extension)
 * Fix problem with hostname in `Settings`
 * Add submit attribute to FormSerializer
 * Only serialize form labels when present
## 0.8.0
 * Add submit label to forms
 * Pass options from respond_with to presenter
 * Add only/except options for path helpers
 * Changed foreign_key syntax
 * Fix ERB trim_mode warnings in ruby2.6
## 0.7.1
 * support let! in specs
 * system spec type
 * Error classes for 409 and 422
 * Fill edit forms with values
 * Add `#authenticate!` helper
 * Drop `#lookup_user_with` helper
 * Fix bug generating migrations, Issue #2
## 0.7.0
 * Skip generating failing integration spec 
 * Add Rake task to list routes
 * Routes should now be specified with `_path`
 * Add helper for checking current path
 * changed path to create forms
 * Add support for before-/after actions
 * Refactored Forms
 * Updated dependencies
## 0.6.0
 * Fix warning/warn logging typo
 * Refactor Formable module (now uses extend)
 * Improvements for upgrades
## 0.5.2
 * Run framework specs with random listen port
 * Remove duplicate link to create form
 * Add logging of response status code
 * Add spec helper to serialize test payload
 * Raise exception when policy does not support action
 * Support symbol routes with same singular/plural name
 * No embedded forms for generated policies
 * Memoize resource lookup in controllers
 * Bug fixes for spec fixtures
## 0.5.1
 * Add `_path` methods for all uri helpers
 * Loading base classes (e.g. base_policy) first
## 0.5.0
 * Add base_uri to all uris
 * Validate foreign key table
 * Base class for serializers and policies
 * Add base_uri to uris
 * Adding/dropping files in upgrades
 * Forms are no longer embedded
 * Add http cache control to forms and docs
 * Remove create form from resources
 * Remove update link from resources
## 0.4.1
 * Add command to show shaf version
 * Fix upgrade problem
 * Shaf::Error - common base for all exceptions 
 * Support HTTP cache headers
## 0.4.0
 * Refactored tasks
 * Support command options
 * Specs not generated unless flag `--specs`
 * Support foreign keys in migrations generators
 * Support add index migrations
 * Add -p, --port option to server command
 * Support db seed files
 * Support nested resources in uri helpers
 * Removed dev dependencies
 * Add support for upgrading projects
## 0.3.1
 * Support spec fixtures
 * Support model names with underscore
 * db:rollback task defaults to one step
 * Accept application/hal+json
 * Support query parameters in uri helpers
## 0.3.0
 * Form fields can be specified as `required`
 * Default implementation of `current_user`
 * Use uri symbols as controller routes
 * Mute warnings when running specs
 * Require all .rb files under src/
 * safe_params now always allows :id
## 0.2.1
 * Add `each_embedded` method to specs
 * Remove duplicate dependency
## 0.2.0
 * Add method to exit with error message to commands
 * Used command with longest matching identifiers
