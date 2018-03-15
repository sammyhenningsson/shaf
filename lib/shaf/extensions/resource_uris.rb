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
      uri = "#{base}/#{plural_name}".freeze

      UriHelperMethods.register("#{plural_name}_uri") { uri }
      UriHelperMethods.register("#{plural_name}_uri_template") { uri }
    end

    def register_resource_uri
      uri = "#{base}/#{plural_name}"

      UriHelperMethods.register "#{name}_uri" do |resrc|
        id = resrc.is_a?(Integer) ? resrc : resrc&.id
        raise ArgumentError, "id must be an integer! was #{id.class}" unless id.is_a?(Integer)
        "#{uri}/#{id}".freeze
      end

      UriHelperMethods.register "#{name}_uri_template" do
        "#{uri}/:id".freeze
      end
    end

    # If a resource has the same singular and plural names, then this method
    # should be used. It will return the resource uri when a resource is given
    # as argument and the resources uri when no arguments are provided.
    def register_resource_uri_by_arg
      uri = "#{base}/#{plural_name}"
      UriHelperMethods.register "#{plural_name}_uri" do |resrc = nil|
        if resrc.nil?
          uri.freeze
        else
          id = (resrc.is_a?(Integer) ? resrc : resrc.id).to_i
          raise ArgumentError, "id must be an integer! was #{id.class}" unless id.is_a?(Integer)
          "#{uri}/#{id}".freeze
        end
      end

      UriHelperMethods.register "#{plural_name}_uri_template" do |collection = false|
        (collection ? uri : "#{uri}/:id").freeze
      end
    end

    def register_new_resource_uri
      uri = "#{base}/#{plural_name}/form".freeze

      UriHelperMethods.register("new_#{name}_uri") { uri }
      UriHelperMethods.register("new_#{name}_uri_template") { uri }
    end

    def register_edit_resource_uri
      uri = "#{base}/#{plural_name}"

      UriHelperMethods.register "edit_#{name}_uri" do |resrc|
        id = resrc.is_a?(Integer) ? resrc : resrc&.id
        "#{uri}/#{id}/edit".freeze unless id.nil?
      end

      UriHelperMethods.register "edit_#{name}_uri_template" do
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
        s = method_name(name)
        s << "(#{args.join(', ')})" unless args.empty?
        s
      end

      def as_string(name, uri)
        signature = signature(name, uri)
        <<~EOM
      def #{signature}
        \"#{interpolated_uri_string(uri)}\".freeze
      end
        EOM
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
