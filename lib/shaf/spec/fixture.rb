require 'shaf/spec/fixtures'
require 'shaf/utils'

module Shaf
  module Spec
    class Fixture
      include Fixtures

      def self.define(collection_name, &block)
        return unless block_given?
        collection = Fixtures.add_collection(collection_name)
        new(collection_name, collection, block).run
      end

      def initialize(collection_name, collection, block)
        @collection_name = collection_name
        @collection = collection
        @block = block
      end

      def run
        instance_exec(&@block)
      end

      def resource(name, resrc = nil, &block)
        @collection[name.to_sym] = resrc || instance_exec(&block)
      end

      private

      def method_missing(method, *args, &block)
        if load_fixture_if_missing_method_is_fixture?(method, *args)
          send(method, args[0])
        elsif resource_alias?(method)
          resource(*args, &block)
        else
          super
        end
      end

      def load_fixture_if_missing_method_is_fixture?(method, *args)
        return false if args.size > 1 # Fixtures should only be called with one argument

        fixture_files = Fixtures.fixture_files
        fixtures = fixture_files.map { |f| File.basename(f, ".rb") }
        i = fixtures.index(method.to_s)
        return false unless i

        require fixture_files[i]
        respond_to? method
      end

      def resource_alias?(method)
        return true if method == :r
        Utils.singularize(@collection_name) == method
      end
    end
  end
end
