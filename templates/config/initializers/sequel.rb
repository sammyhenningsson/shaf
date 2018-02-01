require 'config/database'

Sequel::Model.plugin :timestamps
DB.extension(:pagination)
