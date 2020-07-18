module Shaf
  module SymbolicRoutes
    class UriHelperNotRegisterdError < Error; end

    Shaf::SUPPORTED_HTTP_METHODS.each do |m|
      define_method m do |path, **options, &block|
        collection = options.delete(:collection)
        path = rewrite_path(path, collection, m)
        super(path, **options, &block)
      end
    end

    def rewrite_path(path, collection, method)
      return path unless path.is_a? Symbol

      warn <<~DEPRECATION unless collection.nil?
        Deprecated use of declaring route with collection keyword argument:
        Use `#{method} :#{path.to_s.sub(/_(path|uri)/, '_collection_path')} do`
        instead of `#{method} :#{path}, collection: #{collection} do`
        #{caller.find { |s| s.match?(/_controller.rb/) }}

      DEPRECATION

      method = "#{path}_template"
      send_args = [method]
      send_args << collection unless collection.nil?
      return send(*send_args) if respond_to? method

      method = "#{path}_path_template"
      return send(*send_args) if respond_to? method

      raise UriHelperNotRegisterdError, <<~RUBY
        Undefined method '#{method}'. Did you forget to register a uri helper for #{path}?
      RUBY
    end
  end
end
