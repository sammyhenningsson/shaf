require 'sinatra/base'

module Shaf
  module ResourceUris
    def resource_uris_for(*args)
      CreateUriMethods.new(*args).call

      include UriHelper unless self < UriHelper
    end

    def register_uri(name, uri)
      if UriHelper.respond_to? MethodBuilder.method_name(name)
        raise "resource uri #{name} can't be registered. Method already exist!"
      end
      method_string = MethodBuilder.as_string(name, uri)
      UriHelperMethods.eval_method(method_string)
      UriHelperMethods.register(MethodBuilder.template_method_name(name)) { uri.dup.freeze }

      include UriHelper unless self < UriHelper
    end
  end

  Sinatra.register ResourceUris

  module UriHelperMethods
    def self.register(name, &block)
      define_method(name, &block)
    end

    def self.eval_method(str)
      class_eval str
    end
  end

  module UriHelper
    extend UriHelperMethods
    include UriHelperMethods

    def self.included(mod)
      mod.extend self
    end
  end

  # This class register uri helper methods like:
  # books_uri             => /books
  # book_uri(book)        => /books/5
  # new_book_uri          => /books/form
  # edit_book_uri(book)   => /books/5/edit
  #
  # And uri template methods:
  # books_uri_template             => /books
  # book_uri_template              => /books/:id
  # new_book_uri_template          => /books/form
  # edit_book_uri_template         => /books/:id/edit
  #
  class CreateUriMethods

    # Resources should never be nested more than 1 level deep.
    MAX_NESTING_DEPTH = 1

    class UriTemplateNestingError < StandardError
      def initialize(msg = nil)
        msg ||= "Uri templates only supports a nesting depth of #{MAX_NESTING_DEPTH}"
        super(msg)
      end
    end

    class UriTemplateVariableError < StandardError
      def initialize(msg = nil)
        msg ||= "Mismatch between uri templates and resources"
        super(msg)
      end
    end

    class << self
      def resource_helper_uri(template_uri, *resources, query)
        uri = replace_templates(template_uri, *resources)
        query_string = MethodBuilder.query_string(query)
        "#{uri}#{query_string}".freeze
      end

      def replace_templates(template_uri, *resources)
        symbols = MethodBuilder.extract_symbols(template_uri)
        resources.compact!
        raise UriTemplateVariableError if symbols.size != resources.size

        MethodBuilder.transform_symbols(template_uri) do |segment|
          resrc = resources.shift
          sym = symbols.shift
          resrc.respond_to?(sym) ? resrc.public_send(sym) : resrc
        end
      end
    end

    def initialize(name, base: nil, plural_name: nil)
      @name = name.to_s
      @base = base&.sub(%r(/\Z), '') || ''
      @plural_name = plural_name&.to_s || Utils::pluralize(name.to_s)

      if nesting_depth > MAX_NESTING_DEPTH
        raise UriTemplateNestingError,
          "Too deep nesting level (max #{MAX_NESTING_DEPTH}): #{@base}"
      end
    end

    def call
      if plural_name == name
        register_resource_uri_by_arg
      else
        register_resources_uri
        register_resource_uri
      end
      register_new_resource_uri
      register_edit_resource_uri
    end

    private

    attr_reader :name, :base, :plural_name

    def register_resources_uri
      template_uri = "#{base}/#{plural_name}".freeze
      helper_name = "#{plural_name}_uri".freeze
      register(template_uri, helper_name)
    end

    def register_resource_uri
      template_uri = "#{base}/#{plural_name}/:id".freeze
      helper_name = "#{name}_uri".freeze
      register(template_uri, helper_name)
    end

    # If a resource has the same singular and plural names, then this method
    # should be used. It will return the resource uri when a resource is given
    # as argument and the resources uri when no arguments are provided.
    def register_resource_uri_by_arg
      resource_template_uri =   "#{base}/#{plural_name}/:id"
      collection_template_uri = "#{base}/#{plural_name}"
      helper_name = "#{plural_name}_uri"

      block = resource_or_collection_method_proc(resource_template_uri, collection_template_uri)
      UriHelperMethods.register(helper_name, &block)
      UriHelperMethods.register("#{helper_name}_template") do |collection = false|
        (collection ? collection_template_uri : resource_template_uri).freeze
      end
    end

    def register_new_resource_uri
      template_uri = "#{base}/#{plural_name}/form".freeze
      helper_name = "new_#{name}_uri".freeze
      register(template_uri, helper_name)
    end

    def register_edit_resource_uri
      template_uri = "#{base}/#{plural_name}/:id/edit".freeze
      helper_name = "edit_#{name}_uri".freeze
      register(template_uri, helper_name)
    end

    def register(template_uri, helper_name)
      block = resource_helper_method_proc(template_uri)
      UriHelperMethods.register(helper_name, &block)
      UriHelperMethods.register("#{helper_name}_template") { template_uri }
    end

    def resource_helper_method_proc(template_uri)
      arg_count = MethodBuilder.extract_symbols(template_uri).size

      case arg_count
      when 0
        ->(**query) do
          CreateUriMethods.resource_helper_uri(template_uri, query)
        end
      when 1
        ->(resrc, **query) do
          CreateUriMethods.resource_helper_uri(template_uri, resrc, query)
        end
      when 2
        ->(parent_resrc, resrc, **query) do
          CreateUriMethods.resource_helper_uri(template_uri, parent_resrc, resrc, query)
        end
      else
        raise UriTemplateNestingError,
          "Too deep nesting level (max #{MAX_NESTING_DEPTH}): #{template_uri}"
      end
    end

    def resource_or_collection_method_proc(resource_template_uri, collection_template_uri)
      case nesting_depth
      when 0
        ->(resrc = nil, **query) {
          args = if resrc.nil?
                   [collection_template_uri, query]
                 else
                   [resource_template_uri, resrc, query]
                 end
          CreateUriMethods.resource_helper_uri(*args)
        }
      when 1
        ->(parent_resrc, resrc = nil, **query) {
          args = if resrc.nil?
                   [collection_template_uri, parent_resrc, query]
                 else
                   [resource_template_uri, parent_resrc, resrc, query]
                 end
          CreateUriMethods.resource_helper_uri(*args)
        }
      else
        raise UriTemplateNestingError,
          "Too deep nesting level (max #{MAX_NESTING_DEPTH}): #{template_uri}"
      end
    end

    def nesting_depth
      MethodBuilder.extract_symbols(base).size
    end
  end

  module MethodBuilder
    class << self
      def method_name(name)
        "#{name}_uri"
      end

      def template_method_name(name)
        "#{method_name(name)}_template"
      end

      def signature(name, uri)
        args = extract_symbols(uri)
        s = "#{method_name(name)}("
        s << (args.empty? ? "**query)" : "#{args.join(', ')}, **query)")
      end

      def query_string(query)
        return "" unless query.any?
        "?#{query.map { |key,value| "#{key}=#{value}" }.join("&")}"
      end

      def as_string(name, uri)
        signature = signature(name, uri)
        <<~Ruby
      def #{signature}
        query_string = MethodBuilder.query_string(query)
        \"#{interpolated_uri_string(uri)}\#{query_string}\".freeze
      end
        Ruby
      end

      def extract_symbols(uri)
        uri.split('/').grep(/:.*/).map { |t| t[1..-1] }.map(&:to_sym)
      end

      def transform_symbols(uri)
        uri.split('/').map do |segment|
          next segment unless segment.start_with? ':'
          yield segment
        end.join('/')
      end

      private

      def interpolated_uri_string(uri)
        return uri if uri == '/'

        transform_symbols(uri) do |segment|
          str = segment[1..-1]
          "\#{#{str}.respond_to?(#{segment}) ? #{str}.#{str} : #{str}}"
        end
      end
    end
  end
end
