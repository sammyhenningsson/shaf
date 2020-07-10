module Shaf
  module Tasks
    class RoutesTask
      extend Rake::DSL

      desc 'List path helpers'
      task :routes do
        require 'shaf/utils'
        require 'config/database'

        extend Shaf::Utils
        bootstrap

        Shaf::ApiRoutes::Registry.controllers.each do |controller|
          puts "\n#{controller}:"
          Shaf::ApiRoutes::Registry.routes_for(controller) do |methods, template, symbol|
            puts format(
              '  %-50<symbol>s%-30<methods>s%<template>s',
              {symbol: symbol, methods: methods.join(' | '), template: template}
            )
          end
        end
      end
    end
  end
end
