require 'set'

module Shaf
  module ApiRoutes
    class Registry
      class << self
        def register(controller, method, symbol, collection)
          symbol = :"#{symbol}__collection__" if collection
          routes[controller][symbol] << method.to_s.upcase
        end

        def controllers
          routes.keys.sort_by(&:to_s)
        end

        def routes_for(controller)
          sorted = routes[controller].keys.sort_by(&:to_s)
          sorted.each do |symbol|
            collection = symbol.match?(/__collection__\Z/)
            yield route_info(controller, symbol, collection)
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

        def route_info(controller, symbol, collection)
          methods = routes[controller][symbol].to_a
          symbol = ensure_path_suffix(symbol)
          template_method = :"#{symbol}_template"

          if controller.respond_to? template_method
            template = controller.public_send(template_method, collection)
          else
            template = symbol
            symbol = '-'
          end

          symbol = "#{symbol} (collection)" if collection

          [methods, template, symbol]
        end

        def ensure_path_suffix(symbol)
          symbol = symbol.to_s.delete_suffix '__collection__'

          case symbol
          when /_path\Z/
            symbol
          when /_uri\Z/
            symbol.to_s.sub(/_uri\Z/, '_path')
          else
            "#{symbol}_path"
          end
        end
      end
    end

    Shaf::SUPPORTED_HTTP_METHODS.each do |method|
      define_method method do |path, **options, &block|
        collection = options[:collection]
        Registry.register(self, method, path, collection)
        super(path, **options, &block)
      end
    end
  end
end
