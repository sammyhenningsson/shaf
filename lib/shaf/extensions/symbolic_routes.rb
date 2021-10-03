module Shaf
  module SymbolicRoutes
    class UriHelperNotRegisterdError < Error; end

    Shaf::SUPPORTED_HTTP_METHODS.each do |m|
      define_method m do |path, **options, &block|
        path = rewrite_path(path, m)
        super(path, **options, &block)
      end
    end

    def rewrite_path(path, method)
      return path unless path.is_a? Symbol

      ["#{path}_template", "#{path}_path_template"].each do |method|
        return send(method) if respond_to? method
      end

      raise UriHelperNotRegisterdError, <<~RUBY
        Undefined method '#{method}'. Did you forget to register a uri helper for #{path}?
      RUBY
    end
  end
end
