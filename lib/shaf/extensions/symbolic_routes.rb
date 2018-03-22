module Shaf
  module SymbolicRoutes
    [
      :get,
      :put,
      :post,
      :patch,
      :delete,
      :head,
      :options,
      :link,
      :unlink
    ].each do |m|
      define_method m do |path, &block|
        super(rewrite_path(path), &block)
      end
    end

    def rewrite_path(path)
      return path unless path.is_a? Symbol

      m = "#{path}_template"
      raise "Don't know how to 'get #{path}'" unless respond_to? m
      send m
    end
  end
end
