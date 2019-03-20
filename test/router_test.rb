# frozen_string_literal: true

require 'test_helper'
require "rack/test"

module Shaf
  describe Router do
    include ::Rack::Test::Methods
    def app
      router
    end

    let(:router_class) { Class.new(Router) }
    let(:router) { router_class.new(controller3) }
    let(:controller1) do
      Class.new(Sinatra::Base) do
        get '/one' do
          [200, {}, 'one1']
        end

        get '/one/:id' do
          [200, {}, 'one2']
        end
      end
    end
    let(:controller2) do
      Class.new(Sinatra::Base) do
        not_found do
          [404, {}, 'nada']
        end

        get '/two/:id' do
          headers = {}
          headers['X-Cascade'] = 'pass' if params[:id] == '7'
          [200, headers, 'two']
        end
      end
    end
    let(:controller3) do
      Class.new(Sinatra::Base) do
        get '/two/:id' do
          [200, {}, 'another_two']
        end
      end
    end

    before do
      router_class.mount controller1
      router_class.mount controller2, default: true
      router_class.mount controller3
    end

    it 'routes to the right controller' do
      get 'one'
      assert_equal 'one1', last_response.body

      get '/one/5'
      assert_equal 'one2', last_response.body

      get '/two/5'
      assert_equal 'two', last_response.body
    end

    it 'finds controller from cache' do
      get '/one/5'
      assert_equal 'one2', last_response.body

      # making the normal lookup return nil resp. [] means that we must have
      # found the controller in the cache. Else we'd get a 404
      router.stub :find, nil do
        router.stub :find_all, [] do
          get '/one/10'
          assert_equal 200, last_response.status
          assert_equal 'one2', last_response.body
        end
      end
    end

    it 'uses the default controller when no match is found' do
      get '/doesnotexist'
      assert_equal 'nada', last_response.body
    end

    it 'can cascade to another controller' do
      get '/two/5'
      assert_equal 'two', last_response.body

      get '/two/7'
      assert_equal 'another_two', last_response.body
    end
  end
end
