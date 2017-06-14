$LOAD_PATH << File.expand_path('.')
require 'rubygems'
require 'bundler'
require 'config/init.rb'
require './app/server'
require './app/routes'

run Server
