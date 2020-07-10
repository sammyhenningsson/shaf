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
          sorted = routes[controller].keys.sort
          sorted.each do |symbol|
            methods = routes[controller][symbol]
            template_method = "#{symbol}_template".to_sym
            next unless controller.respond_to? template_method

            template = controller.public_send(template_method)

            yield [methods, template, symbol]
          end
        end

        private

        def routes
          @routes ||= Hash.new do |hash, key|
            hash[key] = Hash.new { |h, k| h[k] = [] }
          end
        end
      end
    end

    Shaf::SUPPORTED_HTTP_METHODS.each do |method|
      define_method method do |path, *args, &block|
        Registry.register(self, method, path)
        super(path, *args, &block)
      end
    end
  end
end
