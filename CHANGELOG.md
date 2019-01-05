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
