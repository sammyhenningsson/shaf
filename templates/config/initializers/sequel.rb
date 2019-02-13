require 'config/database'

Sequel::Model.plugin :timestamps
Sequel.extension :blank
DB.extension(:pagination)
