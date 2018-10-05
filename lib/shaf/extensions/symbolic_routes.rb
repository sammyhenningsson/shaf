module Shaf
  module SymbolicRoutes
    class UriHelperNotRegisterdError < Error; end

    SUPPORTED_METHODS = [
      :get,
      :put,
      :post,
      :patch,
      :delete,
      :head,
      :options,
      :link,
      :unlink
    ].freeze

    SUPPORTED_METHODS.each do |m|
      define_method m do |path, collection: false, &block|
        super(rewrite_path(path, collection), &block)
      end
    end

    def rewrite_path(path, collection = nil)
      return path unless path.is_a? Symbol

      m = "#{path}_template"
      return send(m, collection) if respond_to? m

      raise UriHelperNotRegisterdError, <<~RUBY
        Undefined method '#{m}'. Did you forget to register a uri helper for #{path}?
      RUBY
    end
  end
end
