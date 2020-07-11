module Shaf
  module SymbolicRoutes
    class UriHelperNotRegisterdError < Error; end

    Shaf::SUPPORTED_HTTP_METHODS.each do |m|
      define_method m do |path, **options, &block|
        collection = options.delete(:collection)
        path = rewrite_path(path, collection)
        super(path, **options, &block)
      end
    end

    def rewrite_path(path, collection = nil)
      return path unless path.is_a? Symbol

      m = "#{path}_template"
      return send(m, collection) if respond_to? m

      m = "#{path}_path_template"
      return send(m, collection) if respond_to? m

      raise UriHelperNotRegisterdError, <<~RUBY
        Undefined method '#{m}'. Did you forget to register a uri helper for #{path}?
      RUBY
    end
  end
end
