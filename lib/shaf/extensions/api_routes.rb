require 'set'

module Shaf
  module ApiRoutes
    class Registry
      class << self
        def register(controller, method, symbol)
          routes[controller][symbol] << method.to_s.upcase
        end

        def controllers
          routes.keys.sort_by(&:to_s)
        end

        def routes_for(controller)
          sorted = routes[controller].keys.sort_by(&:to_s)
          sorted.each do |symbol|
            yield route_info(controller, symbol)
          end
        end

        private

        def routes
          @routes ||= Hash.new do |hash, key|
            # Group routes with conditionals together (`Set.new`). Like:
            # get(:foobar_path, agent: /ios/) { "ios specific" }
            # get(:foobar_path, agent: /android/) { "android specific" }
            hash[key] = Hash.new { |h, k| h[k] = Set.new }
          end
        end

        def route_info(controller, symbol)
          methods = routes[controller][symbol].to_a
          template_method = :"#{symbol}_template"

          if controller.respond_to? template_method
            template = controller.public_send(template_method)
          else
            template = symbol
            symbol = '-'
          end

          [methods, template, symbol]
        end
      end
    end

    Shaf::SUPPORTED_HTTP_METHODS.each do |method|
      define_method method do |path, **options, &block|
        path_str = path.to_s
        path_str.sub!(/_uri/, '_path')
        path_str = "#{path_str}_path" unless path_str.end_with? '_path'
        path_str.sub!(/_path/, '_collection_path') if options[:collection]
        Registry.register(self, method, path_str.to_sym)
        super(path, **options, &block)
      end
    end
  end
end
