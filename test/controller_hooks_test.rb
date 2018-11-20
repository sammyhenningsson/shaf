require 'test_helper'
require 'ostruct'

module Shaf
  describe ControllerHooks do
    let(:before_args) { [] }
    let(:before_stub) do
      lambda do |*args, &block|
        result = controller.new.instance_exec(&block)
        before_args << [*args, result]
      end
    end
    let(:controller) do
      Class.new do
        extend ControllerHooks
        extend ResourceUris
        resource_uris_for :post
        register_uri :archive_post, '/posts/:id/archive'
        def self.before; end
        def callback; 'return_value_from_controller_cb'; end
      end
    end

    after do
      UriHelperMethods.remove_all
    end

    it 'adds hooks to controller' do
      assert controller.respond_to? :before_action, true
      assert controller.respond_to? :after_action, true
    end

    it 'registers method as callback' do
      controller.stub :before, before_stub do
        controller.before_action(:callback, only: :post_path)
        before_args.size.must_equal 1
        before_args[0][1].must_equal 'return_value_from_controller_cb'
      end
    end

    it 'registers block as callback' do
      controller.stub :before, before_stub do
        controller.before_action(only: :post_path) { 'foobar' }
        before_args.size.must_equal 1
        before_args[0].size.must_equal 2
        before_args[0][1].must_equal 'foobar'
      end
    end

    it 'passes a regexp as filter' do
      controller.stub :before, before_stub do
        controller.before_action(only: :post_path) { 'foobar' }
        before_args.size.must_equal 1
        before_args[0].size.must_equal 2
        before_args[0][0].must_equal %r{/posts/\w+/?}
      end
    end

    it 'regesters all uri_methods' do
      controller.stub :before, before_stub do
        controller.before_action(:callback)
        before_args.size.must_equal(
          %w[posts_path post_path new_post_path edit_post_path archive_post_path].size
        )
      end
    end

    it 'can exclude a uri by symbol' do
      controller.stub :before, before_stub do
        controller.before_action(:callback, except: :post_path)
        before_args.size.must_equal(
          %w[posts_path new_post_path edit_post_path archive_post_path].size
        )
      end
    end

    it 'can excludes an array of symbols' do
      controller.stub :before, before_stub do
        controller.before_action(:callback, except: [:post_path, :edit_post_path])
        before_args.size.must_equal(
          %w[posts_path new_post_path archive_post_path].size
        )
      end
    end
  end
end
