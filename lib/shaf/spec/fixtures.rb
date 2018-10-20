module Shaf
  module Spec
    module Fixtures
      class FixtureNotFound < StandardError
        def initialize(name, key = nil)
          msg =
            if key
              "Instance '#{key}' is not found in fixture '#{name}'! " \
                "Either it does not exist in the fixture definition or " \
                "there is a circular dependency with your fixtures."
            else
              "No such fixture: #{name}"
            end

          super(msg)
        end
      end

      class << self
        def load(reload: false)
          clear if reload
          require_fixture_files
          init_fixtures
        end

        def clear
          fixtures.each { |name, _| Accessors.clear(name) }
          @initialized_fixtures = []
        end

        def init_fixtures
          fixtures.each { |name, fixture| init_fixture(name, fixture) }
        end

        def init_fixture(name, fixture = nil)
          fixture ||= fixtures[name]
          raise FixtureNotFound, name unless fixture
          return if initialized? name

          initialized_fixtures << name
          fixture.init
        end

        def fixture_defined(fixture)
          fixtures[fixture.name] = fixture
          Accessors.add(fixture.name)
        end

        def fixtures
          @fixtures ||= {}
        end

        def initialized_fixtures
          @initialized_fixtures ||= []
        end

        def require_fixture_files
          fixture_files.each { |file| require(file) }
        end

        def fixture_files
          @fixture_files ||= Dir[File.join(fixture_dir, '**', '*.rb')]
        end

        def fixture_dir
          Shaf::Settings.fixtures_dir || 'spec/fixtures'
        end

        def initialized?(name)
          initialized_fixtures.include? name
        end
      end

      module Accessors
        class << self
          def collection(name)
            @collections ||= {}
            @collections[name] ||= {}
          end

          def clear(name)
            collection(name).clear
          end

          def add(name)
            collection = collection(name)
            return if instance_methods.include? name

            define_method(name) do |arg = nil|
              Fixtures.init_fixture(name) unless Fixtures.initialized? name
              if arg.nil?
                collection
              elsif collection.key? arg
                collection[arg]
              else
                raise FixtureNotFound.new(name, arg)
              end
            end
          end
        end
      end
    end
  end
end
