## Testing
Shaf helps you to spec your serializers and integration with `MiniTest::Spec`. Specs inheriting from `Shaf::Spec::Base` has a few helper methods, e.g. `::let!`, and are always executed inside a transaction that gets rolled back after each test. System, Integration and Serializer specs inherits `Shaf::Spec::Base`.

#### System specs
System specs are created by passing keyword argument `type: :system` to `describe`, such as `describe "Posts", type: :system do; end`.

#### Serializer specs
The description for a Serializer spec MUST end with 'Serializer', such as `describe PostSerializer do; end`. This will make the spec include `Shaf::Spec::PayloadUtils`, which adds some utility methods. The method `set_payload(payload)` may be used for specifying a payload that should be tested. After setting a payload, it is possible to use the following methods that will extract values from the payload passed to `set_payload`:
- `attributes`
- `links`
- `link_rels`
- `embedded_resources`
- `embedded(name, &block)`  
- `each_embedded(name, &block)`  

Given a serializer `FooSerializer` that renders attributes `:foo` and `:bar`, but not `:baz` as well as a _self_ link and a _some_action_ link. Then a simple spec might look like this:
```sh
require 'ostruct'

describe FooSerializer do
  let(:resource) do
    Ostruct.new(foo: 1, bar: 2, baz: 4)
  end

  before do
    set_payload FooSerializer.to_hal(resource)
  end

  it "serializes attributes" do
    _(attributes.keys).must_include(:foo)
    _(attributes.keys).must_include(:bar)
    _(attributes.keys).wont_include(:baz)
  end

  it "serializes links" do
    _(link_rels).must_include(:self)
    _(link_rels).must_include(:some_action)
  end
end
```

The method `embedded(name, &block)` is used to verify attributes and links inside embedded resources (it can also be called without a block, then the embedded resource will simply be returned instead). Given a serializer `BarSerializer` that embeds `Foo` resources then a spec might look like this:
```sh
require 'ostruct'

describe BarSerializer do
  let(:resource) do
    foo = Ostruct.new(bar: 2, baz: 4)
    Ostruct.new(name: 'test', foo: foo)
  end

  before do
    set_payload BarSerializer.to_hal(resource)
  end

  it "embeds a foo resource" do
    embedded :foo do
      _(attributes.keys).must_include(:foo)
      _(attributes.keys).must_include(:bar)
      _(attributes.keys).wont_include(:baz)

      _(link_rels).must_include(:self)
      _(link_rels).must_include(:some_action)
    end
  end
end
```
If an embedded resource is an array of resources, then `each_embedded(name, &block)` can be used to iterate through each embedded resource.
```sh
require 'ostruct'

describe BarSerializer do
  let(:resource) do
    foo = [Ostruct.new(bar: 2, baz: 4), Ostruct.new(bar: 3, baz: 8)]
    Ostruct.new(name: 'test', foo: foo)
  end

  before do
    set_payload BarSerializer.to_hal(resource)
  end

  it "all embeded foo resources has correct attributes and links" do
    each_embedded :foo do
      _(attributes.keys).must_include(:foo)
      _(attributes.keys).must_include(:bar)
      _(attributes.keys).wont_include(:baz)

      _(link_rels).must_include(:self)
      _(link_rels).must_include(:some_action)
    end
  end
end
```

#### Integration specs
Integration specs are created by passing keyword argument `type: :integration` to `describe`, such as `describe "Posts", type: :integration do; end`. This will include `Rack::Test::Methods`, `Shaf::UriHelper` and `Shaf::Spec::PayloadUtils`. The combination of the methods added by these modules gives integration specs a kind of [Capybara](https://github.com/teamcapybara/capybara) touch. Example:
```sh
require 'spec_helper'

describe "Post", type: :integration do
  it "can create posts" do
    get posts_uri

    embedded :'create-form' do
      _(links[:self][:href]).must_equal new_post_uri
      _(attributes[:href]).must_equal posts_uri
      _(attributes[:method]).must_equal "POST"
      _(attributes[:name]).must_equal "create-post"
      _(attributes[:title]).must_equal "Create Post"
      _(attributes[:type]).must_equal "application/json"
      _(attributes[:fields].size).must_equal 1

      payload = fill_form attributes[:fields]
      post posts_uri, payload
      _(status).must_equal 201
      _(link_rels).must_include(:self)
      _(headers["Location"]).must_equal links[:self][:href]
    end

    get posts_uri
    _(status).must_equal 200
    _(links[:self][:href]).must_include posts_uri
    _(embedded(:posts).size).must_equal 1

    all_messages = embedded(:posts).map { |post| post[:message] }
    _(all_messages).must_include("value for message")
  end
end
```
This spec will:
- start by fetching the posts_uri (e.g. `GET /posts`). This will call `set_payload(response)` behind the scenes.
- Verify that the response embeds a resource with rel `create-form` with some speced attributes.
- Build a new payload with the cryptic call to `fill_form` which just adds some jibrish values for each attribute.
- Post this payload to the form `href`.
- Verify HTTP Status code and HTTP Location header.
- Fetch the posts_uri again.
- Verify that the new resource created in step 4 is included in the response.

#### Fixtures
Shaf loads any fixture files found in `specs/fixtures/*.rb`. A fixture is looks like this:
```ruby
Shaf::Spec::Fixture.define :users do
  alice User.create(email: "alice@test.io")
  bob   User.create(email: "bob@test.io")
end
```
The fixture above will create two resources before all specs are run. They can be retrieved in specs with `users(:alice)` resp. `users(:bob)`, where "users" is the argument passed to `Shaf::Spec::Fixture.define` and alice/bob is from inside the block (created via `method_missing`). You may also use fixtures inside other fixture. For example:
```ruby
Shaf::Spec::Fixture.define :posts do
  by_alice1 Post.create(message: "lorem ipsum", author: users(:alice))
  by_alice2 Post.create(message: "dolor sit", author: users(:alice))
end
```
(Which would of course be retrieved via `posts(:by_alice1)` and `posts(:by_alice2)`)

#### `::let!`
Specs inheriting from `Shaf::Spec::Base` (E.g. Serializer, Integration and System specs) adds a `::let!` method similar to rspec.

#### Running specs
Specs are executed with `shaf test`, which will run all specs. It's also possible to give one more filter arguments to this command. A filter is made up of a pattern and a `:` separated list of line numbers. This is easier explained with some examples:
```ruby
shaf test                                               # Run all specs
shaf test user_serializer_spec.rb                       # Run all specs in user_serializer_spec.rb
shaf test user_serializer_spec.rb:15                    # Run a single spec that covers line 15 in user_serializer_spec.rb
shaf test user_serializer_spec.rb:15:35                 # Run two specs that covers line 15 resp 35 in user_serializer_spec.rb
shaf test user                                          # Run all specs in all files matching `/user/`
shaf test user_serializer_spec.rb:15 users_controller   # Run spec on line 15 in user_serializer_spec.rb and all specs in files matching `/users_controller/`
```
