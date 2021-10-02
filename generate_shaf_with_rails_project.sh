#!/bin/bash

set -x

name=${1:-rails_n_shaf}

rm -rf $name
rails new $name --skip-action-mailer --skip-action-mailbox --skip-action-text --skip-active-job --skip-active-storage --skip-action-cable --skip-javascript
cd "$name/"

# rails generate might hang unless we generate new binstubs
bundle install --binstubs

git init .
git add .
git commit -m "fresh rails project"

rails g scaffold Post title:string message:string
rails db:migrate

rails runner 'Post.create(title: "hello", message: "world")'

yes | rails app:update:bin

git add .
git commit -m "Add rails scaffolding for posts"

if [ -n "$SHAF_PATH" ]; then
    shaf_path=", path: '$SHAF_PATH'"
fi

cat >> Gemfile <<GEMS

# Gems needed by shaf REST framework
gem 'shaf'$shaf_path
gem 'sinatra', require: 'sinatra/base'
gem 'rake'
gem 'sequel'
gem 'sinatra-sequel'
gem 'bcrypt'
gem 'hal_presenter'
gem 'redcarpet'
gem 'yard'
GEMS

bundle exec shaf new rest

cat > config/routes.rb <<ROUTES
\$LOAD_PATH << File.expand_path('rest')
Dir.chdir('rest') do
  require 'config/bootstrap'
end

Rails.application.routes.draw do
  resources :posts
  resources :users
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html

  # Mount the Shaf REST API
  mount Shaf::App => '/api'
end
ROUTES

sed -i 's#/#/api#' rest/api/controllers/root_controller.rb
sed -i 's#/#/api/#' rest/api/controllers/docs_controller.rb

# Using Gemfile in Rails project
rm rest/Gemfile

git add .
git commit -m "Add new shaf api"

cd rest
bundle exec shaf g scaffold api/post title:string message:string --skip-model

git add .
git commit -m "Add shaf scaffolding for posts"

# bundle exec shaf test
