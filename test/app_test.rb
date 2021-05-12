require 'test_helper'
require 'rack/builder'

module Shaf
  describe App do
    let(:mock_app) do
      app = ->(env) { [200, env.fetch(:headers, {}), 'body'] }
      ->(&block) { Rack::Builder.new(app, &block) }
    end

    let(:env) do
      {
        'rack.input' => '',
        'REQUEST_METHOD' => 'GET',
        'PATH_INFO' => '/foobar'
      }
    end

    let(:middleware_class) do
      Class.new do
        def self.name(name = nil)
          @name = name if name
          @name
        end

        def initialize(app)
          @app = app
        end

        def call(env)
          env[:headers] ||= {}
          env[:headers][:trace] ||= []
          env[:headers][:trace] << self.class.name
          env[:headers][self.class.name] = extra if extra
          @app.call(env)
        end

        def extra
          @extra ||= data
        end

        def data; end
      end
    end

    let(:middleware_without_args) do
      Class.new(middleware_class) do
        name :without_args
      end
    end

    let(:middleware_with_args) do
      Class.new(middleware_class) do
        name :with_args

        def initialize(app, *args)
          super(app)
          @args = args
        end

        def data
          @args.join ' '
        end
      end
    end

    let(:middleware_with_kwargs) do
      Class.new(middleware_class) do
        name :with_kwargs

        def initialize(app, **kwargs)
          super(app)
          @kwargs = kwargs
        end

        def data
          @kwargs.map { |a| a.join '=' }.join ' '
        end
      end
    end

    let(:middleware_with_block) do
      Class.new(middleware_class) do
        name :with_block

        def initialize(app, &block)
          super(app)
          @block = block
        end

        def data
          @block.call.to_s
        end
      end
    end

    after do
      # Clear the memoized instance
      App.instance_variable_set(:@instance, nil)
    end

    it 'runs app with port from settings' do
      Settings.port = 1337

      Router.stub :new, mock_app do
        App.call(env)
      end

      # settings is delegated to Sinatra::Application through Sinatra::Delegator
      assert_equal 1337, Sinatra::Application.port
    end

    it 'runs app with middleware' do
      Router.stub :new, mock_app do
        App.use middleware_with_args, 1, 2
        App.use middleware_with_kwargs, x: 3, y: 4
        App.use middleware_without_args

        status, headers, body = App.call(env)

        assert_equal 200, status
        assert_equal [:with_args, :with_kwargs, :without_args], headers[:trace]
        assert_equal 'body', body
      end
    end

    it 'instantiates middleware with positional args' do
      Router.stub :new, mock_app do
        App.use middleware_with_args, "foo", 5

        _status, headers, _body = App.call(env)

        assert_equal "foo 5", headers[:with_args]
      end
    end

    it 'instantiates middleware with keyword args' do
      Router.stub :new, mock_app do
        App.use middleware_with_kwargs, foo: '1', bar: 2

        _status, headers, _body = App.call(env)

        assert_equal "foo=1 bar=2", headers[:with_kwargs]
      end
    end

    it 'instantiates middleware with block' do
      Router.stub :new, mock_app do
        App.use middleware_with_block do
          'foobar'
        end

        _status, headers, _body = App.call(env)

        assert_equal "foobar", headers[:with_block]
      end
    end
  end
end
