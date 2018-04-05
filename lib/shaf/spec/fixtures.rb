module Shaf
  module Spec

    class FixtureNotFound < StandardError; end

    module Fixtures
      def self.load
        fixture_files.map { |file| require file }
      end

      def self.fixture_files
        dir = Shaf::Settings.fixtures_dir || 'spec/fixtures'
        Dir[File.join(dir, '**', '*.rb')]
      end

      def self.add_collection(collection_name)
        @collections ||= {}
        collection_name = collection_name.to_sym unless collection_name.is_a? Symbol
        return if @collections.key? collection_name

        @collections[collection_name] = {}
        collection = @collections[collection_name]
        create_accessor(collection, collection_name)
        collection
      end

      def self.create_accessor(collection, collection_name)
        define_method(collection_name) do |name|
          collection[name.to_sym] or raise FixtureNotFound
        end
      end
    end
  end
end
