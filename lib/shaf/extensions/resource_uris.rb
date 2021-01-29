require 'sinatra/base'

module Shaf
  module ResourceUris
    class UriHelperMethodAlreadyExistError < Error
      def initialize(resource_name, method_name)
        super(
          "resource uri #{resource_name} can't be registered. " \
          "Method :#{method_name} already exist!"
        )
      end
    end

    class << self
      def resource_uris_for(name, **kwargs)
        CreateUriMethods.new(name, **kwargs).call
      end

      def register_uri(name, uri)
        MethodBuilder.new(name, uri).call
      end
    end

    def resource_uris_for(name, **kwargs)
      result = ResourceUris.resource_uris_for(name, **kwargs)
      UriHelperMethods.add_path_helpers(self, result)

      include UriHelper unless self < UriHelper
    end

    def register_uri(name, uri)
      result = ResourceUris.register_uri(name, uri)
      UriHelperMethods.add_path_helpers(self, result)

      include UriHelper unless self < UriHelper
    end
  end

  Sinatra.register ResourceUris

  module UriHelperMethods
    class << self
      def register(name, &block)
        define_method(name, &block)
      end

      def eval_method(str)
        class_eval str
      end

      def add_path_helpers(clazz, methods)
        path_helpers[clazz].concat Array(methods)
      end

      def path_helpers_for(clazz = nil)
        return path_helpers unless clazz
        path_helpers[clazz]
      end

      def path_helpers
        @path_helpers ||= Hash.new { |hash, key| hash[key] = [] }
      end

      # For cleaning up after tests
      def remove_all
        helpers = instance_methods - [:path_helpers]
        remove_method(*helpers)
        @path_helpers = Hash.new { |hash, key| hash[key] = [] }
      end
    end

    def path_helpers
      clazz = is_a?(Class) ? self : self.class
      UriHelperMethods.path_helpers_for clazz
    end
  end

  module UriHelper
    extend UriHelperMethods
    include UriHelperMethods

    def self.included(mod)
      mod.extend self
    end

    def self.base_uri
      return Settings.base_uri if Settings.base_uri

      protocol = Settings.protocol || 'http'
      host = Settings.hostname || 'localhost'
      port = Settings.port ? ":#{Settings.port}" : ""
      "#{protocol}://#{host}#{port}"
    end
  end

  # This class register uri helper methods like:
  # books_uri             => /books
  # book_uri(book)        => /books/5
  # new_book_uri          => /book/form
  # edit_book_uri(book)   => /books/5/edit
  #
  # And uri template methods:
  # books_uri_template             => /books
  # book_uri_template              => /books/:id
  # new_book_uri_template          => /book/form
  # edit_book_uri_template         => /books/:id/edit
  #
  class CreateUriMethods
    def initialize(name, base: nil, plural_name: nil, only: nil, except: nil)
      @name = name.to_s
      @base = base&.sub(%r(/\Z), '') || ''
      @plural_name = plural_name&.to_s || Utils::pluralize(name.to_s)
      @only = only
      @except = except
      @added_path_methods = []
    end

    def call
      if plural_name == name
        # Deprecated code path
        # Remove this branch and only keep the `else` behavior when dropping
        # support for this
        register_resource_helper_by_arg
      else
        register_collection_helper
        register_resource_helper
      end

      register_new_resource_helper
      register_edit_resource_helper
      @added_path_methods
    end

    private

    attr_reader :name, :base, :plural_name, :only, :except

    def register_collection_helper
      return if skip? :collection

      template_uri = "#{base}/#{plural_name}".freeze
      method_name = plural_name
      method_name = "#{name}_collection" if name == @plural_name
      register(method_name, template_uri)
    end

    def register_resource_helper
      return if skip? :resource

      template_uri = "#{base}/#{plural_name}/:id".freeze
      register(name, template_uri)
    end

    # If a resource has the same singular and plural names, then this method
    # should be used. It will return the resource uri when a resource is given
    # as argument and the resources uri when no arguments are provided.
    def register_resource_helper_by_arg
      return register_resource_helper if skip? :collection
      register_collection_helper
      return if skip? :new

      resource_template_uri =   "#{base}/#{plural_name}/:id"
      collection_template_uri = "#{base}/#{plural_name}"

      builder = MethodBuilder.new(name, resource_template_uri, alt_uri: collection_template_uri)
      @added_path_methods << builder.call
    end

    def register_new_resource_helper
      return if skip? :new

      template_uri = "#{base}/#{name}/form".freeze
      register("new_#{name}", template_uri)
    end

    def register_edit_resource_helper
      return if skip? :edit

      template_uri = "#{base}/#{plural_name}/:id/edit".freeze
      register("edit_#{name}", template_uri)
    end

    def register(name, template_uri)
      builder = MethodBuilder.new(name, template_uri)
      @added_path_methods << builder.call
    end

    def skip? name
      if only
        !Array(only).include? name
      elsif except
        Array(except).include? name
      else
        false
      end
    end
  end

  class MethodBuilder
    NO_GIVEN_VALUE = Object.new

    def self.query_string(query)
      return '' unless query&.any?

      fragment_id = query.delete(:fragment_id)
      fragment_str = "##{fragment_id}" if fragment_id

      query_str = query.map { |a| a.join('=') }.join('&')
      query_str = "?#{query_str}" unless query_str.empty?

      [query_str, fragment_str].join
    end

    def initialize(name, uri, alt_uri: nil)
      @name = name
      @uri = uri.dup.freeze
      @alt_uri = alt_uri.dup.freeze
    end

    def call
      if UriHelper.respond_to? uri_method_name
        exception = ResourceUris::UriHelperMethodAlreadyExistError
        raise exception.new(name, uri_method_name)
      end

      if alt_uri.nil?
        build_methods
      else
        build_methods_with_optional_arg
      end
    end

    private

    attr_reader :name, :uri, :alt_uri

    def build_methods
      UriHelperMethods.eval_method uri_method_string
      UriHelperMethods.eval_method path_method_string
      UriHelperMethods.register(template_method_name, &template_proc)
      UriHelperMethods.register(legacy_template_method_name, &template_proc)
      UriHelperMethods.register(path_matcher_name, &path_matcher_proc)
      path_method_name.to_sym
    end

    def build_methods_with_optional_arg
      UriHelperMethods.eval_method uri_method_with_optional_arg_string
      UriHelperMethods.eval_method path_method_with_optional_arg_string
      UriHelperMethods.register(template_method_name, &template_proc)
      UriHelperMethods.register(legacy_template_method_name, &template_proc)
      UriHelperMethods.register(path_matcher_name, &path_matcher_proc)
      path_method_name.to_sym
    end

    def uri_method_name
      "#{name}_uri".freeze
    end

    def path_method_name
      "#{name}_path".freeze
    end

    def path_matcher_name
      :"#{path_method_name}?"
    end

    def template_method_name
      "#{path_method_name}_template".freeze
    end

    def legacy_template_method_name
      "#{uri_method_name}_template".freeze
    end

    def uri_signature(uri: @uri, optional_args: 0)
      signature(uri_method_name, uri, optional_args: optional_args)
    end

    def path_signature(uri: @uri, optional_args: 0)
      signature(path_method_name, uri, optional_args: optional_args)
    end

    def signature(method_name, uri, optional_args: 0)
      args = extract_symbols(uri).size.times.map { |i| "arg#{i}" }
      sym_count = args.size

      optional_args.times { |i| args << "arg#{sym_count + i} = nil" }
      args << '**query'

      "#{method_name}(#{args.join(', ')})"
    end

    def uri_method_string
      base_uri = UriHelper.base_uri
      <<~RUBY
        def #{uri_signature}
          query_str = Shaf::MethodBuilder.query_string(query)
          \"#{base_uri}#{interpolated_uri_string(uri)}\#{query_str}\".freeze
        end
      RUBY
    end

    def path_method_string
      <<~RUBY
        def #{path_signature}
          query_str = Shaf::MethodBuilder.query_string(query)
          \"#{interpolated_uri_string(uri)}\#{query_str}\".freeze
        end
      RUBY
    end

    def uri_method_with_optional_arg_string
      base_uri = UriHelper.base_uri
      arg_no = extract_symbols(alt_uri).size
      <<~RUBY
        def #{uri_signature(uri: alt_uri, optional_args: 1)}
          query_str = Shaf::MethodBuilder.query_string(query)
          if arg#{arg_no}.nil?
            warn <<~DEPRECATION

              Deprecated use of collection uri helper:
              To get the collection uri use ##{name}_collection_uri instead of ##{uri_method_name}.
              Or pass an argument to ##{uri_method_name} to get the uri to a resource.
                \#{caller.find { |s| !s.match? %r{lib/shaf/extensions/resource_uris.rb} }}

            DEPRECATION

            \"#{base_uri}#{interpolated_uri_string(alt_uri)}\#{query_str}\".freeze
          else
            \"#{base_uri}#{interpolated_uri_string(uri)}\#{query_str}\".freeze
          end
        end
      RUBY
    end

    def path_method_with_optional_arg_string
      arg_no = extract_symbols(alt_uri).size
      <<~RUBY
        def #{path_signature(uri: alt_uri, optional_args: 1)}
          query_str = Shaf::MethodBuilder.query_string(query)
          if arg#{arg_no}.nil?
            warn <<~DEPRECATION

              Deprecated use of collection path helper:
              To get the collection path use ##{name}_collection_path instead of ##{path_method_name}.
              Or pass an argument to ##{path_method_name} to get the path to a resource.
                \#{caller.find { |s| !s.match? %r{lib/shaf/extensions} }}

            DEPRECATION

            \"#{interpolated_uri_string(alt_uri)}\#{query_str}\".freeze
          else
            \"#{interpolated_uri_string(uri)}\#{query_str}\".freeze
          end
        end
      RUBY
    end

    def extract_symbols(uri = @uri)
      uri.split('/').grep(/\A:.+/).map { |t| t[1..-1].to_sym }
    end

    def transform_symbols(uri)
      i = -1
      uri.split('/').map do |segment|
        next segment unless segment.start_with? ':'
        i += 1
        yield segment, i
      end.join('/')
    end

    def interpolated_uri_string(uri)
      return uri if uri == '/'

      transform_symbols(uri) do |segment, i|
        # if the uri is templated (starting with a '{'), then we need to
        # exclude it from the interpolated string but add it back to the end of
        # the segment.
        last = (segment.index('{') || 0) - 1
        sym = segment[1..last]
        template = segment[(last + 1)..-1] unless last == -1
        "\#{arg#{i}.respond_to?(:#{sym}) ? arg#{i}.#{sym} : arg#{i}}#{template}"
      end
    end

    def template_proc
      uri, alt_uri = @uri, @alt_uri

      if alt_uri.nil?
        -> { uri }
      else
        deprecated_method = template_method_name
        replacing_method = "#{name}_collection_path_template"

        lambda do |collection = NO_GIVEN_VALUE|
          if collection != NO_GIVEN_VALUE
            warn <<~DEPRECATION

              Deprecated use of uri template helper with `collection` argument:
              Use #{replacing_method} instead of #{deprecated_method}"
                #{caller.find { |s| !s.match? %r{lib/shaf/extensions} }}

            DEPRECATION
          else
            collection = false
          end

          collection ? alt_uri : uri
        end
      end
    end

    def path_mather_patterns
      [
        uri.gsub(%r{:[^/]*}, '\w+'),
        alt_uri&.gsub(%r{:[^/]*}, '\w+')
      ].compact.map { |str| Regexp.new("\\A#{str}\\Z") }
    end

    def path_matcher_proc
      patterns = path_mather_patterns

      deprecated_method = path_matcher_name
      replacing_method = "#{name}_collection_path?"

      lambda do |path = nil, collection: NO_GIVEN_VALUE|
        if collection != NO_GIVEN_VALUE
          warn <<~DEPRECATION

            Deprecated use of uri predicate helper with `collection` argument:
            Use #{replacing_method} instead of #{deprecated_method}(collection: true)
              #{caller.find { |s| !s.match? %r{lib/shaf/extensions} }}

          DEPRECATION
        else
          collection = false
        end

        unless path
          r = request if respond_to? :request
          path = r.path_info if r&.respond_to? :path_info

          unless path
            raise(
              ArgumentError,
              "Uri must be given (or #{self} should respond to :request)"
            )
          end
        end
        pattern = collection ? patterns.last : patterns.first
        !!(pattern =~ path)
      end
    end
  end
end
