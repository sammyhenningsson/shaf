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
    def initialize(name, base: nil, plural_name: nil)
      @name = name.to_s
      @base = base&.sub(%r(/\Z), '') || ''
      @plural_name = plural_name&.to_s || name.to_s + 's'
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
      uri = "#{base}/#{plural_name}"
      helper_name = "#{plural_name}_uri"

      UriHelperMethods.register(helper_name) do |**query|
        query_string = MethodBuilder.query_string(query)
        "#{uri}#{query_string}".freeze
      end
      UriHelperMethods.register("#{helper_name}_template") { uri.freeze }
    end

    def register_resource_uri
      uri = "#{base}/#{plural_name}"
      helper_name = "#{name}_uri"

      UriHelperMethods.register helper_name do |resrc, **query|
        id = resrc.is_a?(Integer) ? resrc : resrc&.id
        query_string = MethodBuilder.query_string(query)

        next "#{uri}/#{id}#{query_string}".freeze if id.is_a?(Integer)
        raise ArgumentError,
          "In #{helper_name}: id must be an integer! was #{id.class}"
      end

      UriHelperMethods.register "#{helper_name}_template" do
        "#{uri}/:id".freeze
      end
    end

    # If a resource has the same singular and plural names, then this method
    # should be used. It will return the resource uri when a resource is given
    # as argument and the resources uri when no arguments are provided.
    def register_resource_uri_by_arg
      uri = "#{base}/#{plural_name}"
      helper_name = "#{plural_name}_uri"

      UriHelperMethods.register helper_name do |resrc = nil, **query|
        query_string = MethodBuilder.query_string(query)

        if resrc.nil?
          "#{uri}#{query_string}".freeze
        else
          id = (resrc.is_a?(Integer) ? resrc : resrc.id).to_i

          next "#{uri}/#{id}#{query_string}".freeze if id.is_a?(Integer)
          raise ArgumentError,
            "In #{helper_name}: id must be an integer! was #{id.class}"
        end
      end

      UriHelperMethods.register "#{helper_name}_template" do |collection = false|
        (collection ? uri : "#{uri}/:id").freeze
      end
    end

    def register_new_resource_uri
      uri = "#{base}/#{plural_name}/form"
      helper_name = "new_#{name}_uri"

      UriHelperMethods.register(helper_name) do |**query|
        query_string = MethodBuilder.query_string(query)
        "#{uri}#{query_string}".freeze
      end
      UriHelperMethods.register("#{helper_name}_template") { uri.freeze }
    end

    def register_edit_resource_uri
      uri = "#{base}/#{plural_name}"
      helper_name = "edit_#{name}_uri"

      UriHelperMethods.register helper_name do |resrc, **query|
        id = resrc.is_a?(Integer) ? resrc : resrc&.id
        query_string = MethodBuilder.query_string(query)

        next "#{uri}/#{id}/edit#{query_string}".freeze if id.is_a?(Integer)
        raise ArgumentError,
          "In #{helper_name}: id must be an integer! was #{id.class}"
      end

      UriHelperMethods.register "#{helper_name}_template" do
        "#{uri}/:id/edit".freeze
      end
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

      private

      def extract_symbols(uri)
        uri.split('/').grep(/:.*/).map { |t| t[1..-1] }.map(&:to_sym)
      end

      def interpolated_uri_string(uri)
        return uri if uri.split('/').empty?

        segments = uri.split('/').map do |segment|
          if segment.start_with? ':'
            str = segment[1..-1]
            "\#{#{str}.respond_to?(#{segment}) ? #{str}.#{str} : #{str}}"
          else
            segment
          end
        end
        segments.join('/')
      end
    end
  end
end
