require 'config/database'

Sequel::Model.plugin :timestamps
Sequel::Model.plugin :validation_helpers
Sequel.extension :blank
DB.extension(:pagination)
