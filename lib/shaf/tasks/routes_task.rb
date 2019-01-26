module Shaf
  module Tasks
    class RoutesTask
      include Rake::DSL

      def initialize(*)
        desc "List path helpers"
        task :routes do
          require 'shaf/utils'
          require 'config/database'

          extend Shaf::Utils
          bootstrap

          helpers = UriHelperMethods.path_helpers_for.sort { |a, b| a[0].to_s <=> b[0].to_s }
          helpers.each do |controller, methods|
            puts "\n#{controller}:"
            methods.each do |method|
              template_method = "#{method}_template".to_sym
              puts sprintf( "%-60s%s" , method, controller.send(template_method))
            end
          end
        end
      end
    end

    RoutesTask.new
  end
end
