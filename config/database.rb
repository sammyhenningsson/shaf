require 'sinatra'
require 'sinatra/sequel'

# Establish the database connection; or, omit this and use the DATABASE_URL
# environment variable as the connection string:
set :database, 'sqlite://db/development.db'

