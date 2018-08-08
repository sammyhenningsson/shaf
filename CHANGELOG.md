## x.x.x
 * Add base_uri to all uris
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
