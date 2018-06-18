# Shaf (Sinatra Hypermedia API Framework)
[![Gem Version](https://badge.fury.io/rb/shaf.svg)](https://badge.fury.io/rb/shaf)  
Shaf is a framework for building hypermedia driven REST APIs. Its goal is to be like a lightweight version of `rails new --api` with hypermedia as a first class citizen. Instead of reinventing the wheel Shaf uses [Sinatra](http://sinatrarb.com/) and adds a layer of conventions similar to [Rails](http://rubyonrails.org/). It uses [Sequel](http://sequel.jeremyevans.net/) as ORM and [HALPresenter](https://github.com/sammyhenningsson/hal_presenter) for policies and serialization (which means that the mediatype being used is [HAL](http://stateless.co/hal_specification.html)).  
Most APIs claiming to be RESTful completly lacks the concept of links and relies upon clients to construction urls to _known_ endpoints. Thoses APIs are missing some important concepts that Roy Fielding put together in is dissertation about REST. Having the server always returning payloads with links (hypermedia) makes the responsibilies more clear and allows for more robust implementations. Clients will then always know what actions are possible and not, depending of which links are present in the server response. For example, there's no need for a client to try to place an order or follow another user unless the server returns the corresponding link for those actions. Also if the server decides to move some resources to another location or change the access protocol (like https instead of http), this can be done without any changes to the client.  
There are many pros and cons about hypermedia APIs, which means that Shaf will not suite everyone. However, if you are going to create an API driven by hypermedia then Shaf will help you, similar to how Rails helps you get up and running in no time. 

## Getting started
Install Shaf with
```sh
gem install shaf
```
Then create a new project with `shaf new` followed by the name of the project. E.g.
```sh
shaf new blog
```
This will create a new directory with a bunch of files that make up the basics of a new API. Change into the this directory and install any missing depencencies.
```sh
cd blog
bundle
```
Your newly created project should contain the following files:
```sh
.
├── api
│   ├── controllers
│   │   ├── base_controller.rb
│   │   ├── docs_controller.rb
│   │   └── root_controller.rb
│   └── serializers
│       ├── error_serializer.rb
│       ├── form_serializer.rb
│       └── root_serializer.rb
├── config
│   ├── bootstrap.rb
│   ├── constants.rb
│   ├── database.rb
│   ├── directories.rb
│   ├── helpers.rb
│   ├── initializers
│   │   ├── db_migrations.rb
│   │   ├── hal_presenter.rb
│   │   ├── logging.rb
│   │   └── sequel.rb
│   ├── initializers.rb
│   └── settings.yml
├── config.ru
├── frontend
│   ├── assets
│   │   └── css
│   │       └── main.css
│   └── views
│       ├── form.erb
│       ├── layout.erb
│       └── payload.erb
├── Gemfile
├── Rakefile
└── spec
    ├── integration
    │   └── root_spec.rb
    ├── serializers
    │   └── root_serializer_spec.rb
    └── spec_helper.rb
```
You should now have a functional API. Start the server with
```sh
shaf server
```
Then in another terminal run
```sh
curl localhost:3000/
```
Which should return the following payload.
```sh
{
  "_links": {
    "self": {
      "href": "http://localhost:3000/"
    }
  }
}
```

_Hint_: The output will actually not have any newlines and will look a bit more dense. To make the output more readable pipe the
curl command to `ruby -rjson -e "puts (JSON.pretty_generate JSON.parse(STDIN.read))"`. E.g.
```sh
curl localhost:3000/ | ruby -rjson -e "puts (JSON.pretty_generate JSON.parse(STDIN.read))"
```
(Or better yet, put it in an alias, e.g. `alias pretty_json='ruby -rjson -e "puts (JSON.pretty_generate JSON.parse(STDIN.read))"'`)

The project also contains a few specs that you can run with `rake`
```sh
rake test
```

Currently your API is pretty useless. Let's fix that by generating some scaffolding. The following command will create a new resource with two attributes (`title` and `message`).
```sh
shaf generate scaffold post title:string message:string 
```
This will output:
```sh
Added:      api/models/post.rb
Added:      db/migrations/20180224225335_create_posts_table.rb
Added:      api/serializers/post_serializer.rb
Added:      spec/serializers/post_serializer_spec.rb
Added:      api/policies/post_policy.rb
Added:      api/controllers/posts_controller.rb
Added:      spec/integration/posts_controller_spec.rb
Modified:   api/serializers/root_serializer.rb
```
As shown in the output, that command created, a model, a controller, a serializer and a policy. It will also generate a DB migration file, some specs and add a link to the new `post` collection in the root resource. So let's check this out by migrating the DB and restarting the server. Close any running instance with `Ctrl + C` and then:
```sh
rake db:migrate
shaf server
```
Again in another terminal run
```sh
curl localhost:3000/ | pretty_json
```
Which should now return the following payload.
```sh
{
  "_links": {
    "self": {
      "href": "http://localhost:3000/"
    },
    "posts": {
      "href": "http://localhost:3000/posts"
    }
  }
}
```
The root payload now contains a link with _rel_ 'posts'. Lets follow that link..
```sh
curl localhost:3000/posts | pretty_json
```
The response looks like this
```sh
{
  "_links": {
    "self": {
      "href": "http://localhost:3000/posts?page=1&per_page=25"
    },
    "up": {
      "href": "http://localhost:3000/"
    },
    "curies": [
      {
        "name": "doc",
        "href": "http://localhost:3000/doc/post/rels/{rel}",
        "templated": true
      }
    ]
  },
  "_embedded": {
    "doc:create-form": {
      "method": "POST",
      "name": "create-post",
      "title": "Create Post",
      "href": "/posts",
      "type": "application/json",
      "_links": {
        "self": {
          "href": "http://localhost:3000/posts/form"
        }
      },
      "fields": [
        {
          "name": "title",
          "type": "string",
          "label": null
        },
        {
          "name": "message",
          "type": "string",
          "label": null
        }
      ]
    },
    "posts": [

    ]
  }
}
```
This is the collection of posts (which currently is empty, see `$response['_embedded']['posts']`). Besides from the emtpy list of posts we also get an embedded form (with rel _doc:create-form_). This form should be used to create a new post.


## HAL
The [HAL](http://stateless.co/hal_specification.html) mediatype is very simple and looks like a any JSON object, except for two reserved keys __links_ and __embedded_. __links_ displays possible actions that may be taken. __embedded_ contains nested resources. A HAL payload may contain a special link with rel _curies_, which is similar to namespaces in XML. Shaf uses a curie called _doc_ and makes it possible to fetch documentation for any link or embedded resources with a rel begining with 'doc:'. The href for curies are always templated, meaning that a part of the href (in our case '{rel}') must be replaced with a value. In the payload above the href of the doc curie is 'http://localhost:3000/doc/post/rels/{rel}' and there is one embedded resource prefixed with 'doc:', namely 'doc:create-form'. So this means that if we would like to find out information about what this embedded resource is and how it relates to the posts collection we replace '{rel}' with 'create-form' and perform a GET request to this url.
```sh
curl http://localhost:3000/doc/post/rels/create-form
```
This documentation is written as code comments in the corresponding serializer. See [Serializers](#Serializers) for more info. Before this documentation can be fetched, a rake task to extract the comments needs to be executed, see [API Documentation](#api-documentation) for more info.   

## Generators
Shaf supports a few different generators to make it easy to create new files. Each generator has an _identifier_ and they are called with `shaf generate IDENTIFIER` plus zero or more arguments.

#### Scaffold
When adding a new resource its recommended to use the scaffold generator. It accepts a resource name and an arbitrary number of attribute:type arguments.
```sh
shaf generate scaffold some_resource attr1:string attr2:integer
```
The scaffold generator will call the model generator and the controller generator, see below.

#### Controller
A new controller is generated with the _controller_ identifier and a resource name and an arbitrary number of attribute:type arguments.
```sh
shaf generate controller some_resource attr1:string attr2:integer
```
This will add a new controller and an integration spec. It will also modify the root resource to include a link the the collection endpoint for _some_resource_.

#### Model
A new model is generated with the _model_ identifier and a resource name and an arbitrary number of attribute:type arguments.
```sh
shaf generate model some_resource attr1:string attr2:integer
```
This will add a new model, call the serializer generator and generate a new db migration to created a new table.

#### Serializer
A new serializer is generated with the _serializer_ identifier, a resource name and an arbitrary number of attribute arguments.
```sh
shaf generate serializer some_resource attr1 attr2
```
This will add a new serializer, a serializer spec and call the policy generator.

#### Policy
A new policy is generated with the _policy_ identifier, a resource name and an arbitrary number of attribute arguments.
```sh
shaf generate policy some_resource attr1 attr2
```
This will add a new policy.

#### Migration
Shaf currently supports 4 db migrations to be generated plus the possibility to generate an empty migration. These are:
```sh
  generate migration
  generate migration add column TABLE_NAME field:type
  generate migration create table TABLE_NAME [field:type] [..]
  generate migration drop column TABLE_NAME COLUMN_NAME
  generate migration rename column TABLE_NAME OLD_NAME NEW_NAME
```
See [the Sequel migrations documentation](http://sequel.jeremyevans.net/rdoc/files/doc/migration_rdoc.html) for more info.
Note: You can also add custom migrations, see [Customizations](#Customizations)

## Routing/Controllers
As usual with Sinatra applications routes are declared together with the controller code rather than in a separate file (as with Rails). All controllers SHOULD be subclasses of `BaseController` found in `api/controllers/base_controller.rb` (which was created along with the project).  
Controllers generated with `shaf generate` uses two Shaf extensions, `Shaf::ResourceUris` and `Shaf::Authorize`.

#### Shaf::ResourceUris
This extension adds two class methods, `resource_uris_for` and `register_uri`. Both methods are used to create uri helpers.  
`resource_uris_for(name, base: nil, plural_name: nil)` - creates four uri helpers and adds them as class methods and instance methods to the caller.
```sh
class PostController < BaseController
  resource_uris_for :post
end
```
Would add the following methods as instance method on Shaf::UriHelper. This module is then both included and extended into the `PostController` (which means that all uri helpers are available as both class methods and instance methods in the controller).  

| Methods                                | Returned string with no query_params (id may vary) | 
| -------------------------------------- | -------------------------------------------------- |
| `posts_uri(**query_params)`            | /posts                                             |
| `post_uri(post, **query_params)`       | /posts/5                                           |
| `new_post_uri(**query_params)`         | /posts/form                                        |
| `edit_post_uri(post, **query_params)`  | /posts/5/edit                                      |

Methods taking an argument (`post_uri` and `edit_post_uri`) may be called with either an integer or an object responding to `:id`. The keyword arguments `:base` and `:plural_name` is used to specify a path namespace (such as '/api') that will be prepended to the uri resp. the pluralization of the name (when excluded the plural name will be `name` + 's').  

The optional `query_params` takes any given keyword arguments and appends a query string with them.  
```sh
  post_uri(post, foo: 'bar')    #  => /posts/5?foo=bar
```

`register_uri` is used to create a single uri helper that does not follow the "normal" conventions of `resource_uris_for`.
```sh
class PostController < BaseController
  register_uri :archive_post, '/posts/:id/archive'
end
```
Would add an `archive_post_uri(post, **query_params)` method to the `PostController` class as well as instances of `PostController`.  
Uri helpers added by `resource_uris_for` and `register_uri` gets added to the module `Shaf::UriHelper` as both module methods and instance methods. So to use them outside of Controllers, either call them directly on the module (e.g. `Shaf::UriHelper.my_foo_uri`) or include `Shaf::UriHelper` and get all helpers as instance methods.  

To make it easier to see the connection between controller routes and uri helpers, Shaf makes it possible to specify routes with symbols. These symbols must be the same as the corresponding uri helper:
```sh
class PostController < BaseController
  register_uri :archive_post '/posts/:id/archive'

  post :archive_post_uri do
    "Post was archived!"
  end
end
```

#### Shaf::Authorize
This module adds an `authorize_with(policy)` class method and an `authorize!(action, resource = nil)` instance method. The class method is used to register a Policy class. The instance method is used to ensure that a certain action is authorized. Given the following policy class (see [Policies](#policies) for more info)
```sh
class PostPolicy
  include HALPresenter::Policy::DSL

  alias post resource

  def show?
    !!current_user
  end

  def edit?
    current_user && current_user.id == post.author.id
  end
end
```
The following controller will make sure that a user must be authenticated to be able to view a post and must be the author of a certain post to be able to edit it.
```sh
class PostController < BaseController
  authorize_with PostPolicy

  get '/posts/:id' do
    authorize! :show

    respond_with post 
  end

  put '/posts/:id/edit' do
    authorize! :edit, post

    post.update(params)
    respond_with post
  end

  private

  def post
    @post ||= Post[params['id']]
  end
end
```
Note: that the Policy instance method MUST end with a question mark '?' while the symbol given to `authorize!` may or may not end with a symbol.  

#### Rendering responses
Shaf controllers includes two helper methods that simplifies rendering responses:
- `respond_with(resource, status: 200, serializer: nil)`
- `respond_with_collection(resource, status: 200, serializer: nil)`

Given that you have a Serializer that is registered to process instances of `Post` (see [Serializers](#serializers) for more info), then a controller route may simply end with `respond_with post` (as shown above) and the response payload will be serialized as expected. Use the keyword arguments, `status` and `serializer`, if you would like to override the default http response code resp. the serializer to be used.


## Models
Models generated with `shaf generate` inherits from `Sequel::Model` (see [Sequel docs](http://sequel.jeremyevans.net/documentation.html) for more info) and they include `Shaf::Formable`. The Formable module adds the class method `form` which Shaf models use to associate two forms with the model. One for creating a new resource and one for editing an extension resource. As an example, the following model will add a create form with fields `foo` and `bar` and an edit form with fields `foo` and `baz`.
```sh
class User < Sequel::Model
  include Shaf::Formable

  form do
    field :foo, type: "string"

    create do
      title 'Create User'
      name  'create-user'
      field :bar, type: "string"
    end

    edit do
      title 'Update User'
      name  'update-user'
      field :baz, type: "integer"
    end
  end
end
```
When serialized these forms contain an array of _fields_ that specifies all attributes that are accepted for create/update. Each field has a `name` property that MUST be used as key when constructing a payload to be submitted. Each field also has a type which declares the kind of value that are accepted (currently only string and integer are supported) and a label that may be used when rendering the form to a user. When submitting the form it MUST be sent to the url in _href_ with the HTTP method specified in _method_ with the Content-Type header set to the value of _type_. Here's the create form from above.
```sh
    "create-form": {
      "method": "POST",
      "name": "create-post",
      "title": "Create Post",
      "href": "/posts",
      "type": "application/json",
      "_links": {
        "self": {
          "href": "http://localhost:3000/posts/form"
        }
      },
      "fields": [
        {
          "name": "title",
          "type": "string",
          "label": null
        },
        {
          "name": "message",
          "type": "string",
          "label": null
        }
      ]
    },
```
A request to submit this form may then look like:
```sh
curl -H "Content-Type: application/json" \
     -d '{"title": "hello", "message": "lorem ipsum"}' \
     localhost:3000/posts
```

## Serializers
Serializers generated with `shaf generate` extends `HALPresenter` and `Shaf::UriHelper`. This means that they have a clean DSL that makes it easy to specify what should be serialized. `Shaf::UriHelper` makes all uri helpers accessible. Serializing a message attribute and a self link is as simple as:
```sh
class PostSerializer
  extend HALPresenter
  extend Shaf::UriHelper

  attribute :message

  link :self do
    post_uri(resource)
  end
end
```
This serializer will send `:message` to the object being serializer and set the returned value in the 'message' property. It will also add a link with rel _self_ and `href` set to the returned value of the corresponding block. `post_uri` comes from `Shaf::UriHelper` and `resource` is a `HALPresenter` method that returns the resource being serialized. See [HALPresenter](https://github.com/sammyhenningsson/hal_presenter) for more information.  
This is also where the api should be documented. Each `attribute`/`link`/`curie`/`embed` directive should be preceeded with comments that document the corresponding usage. See [API Documentation](#api-documentation) for more info.

## Policies
Policies generated with `shaf generate` includes `HALPresenter::Policy::DSL`. This means that they have a DSL that makes it easy to specify which attributes/links/embedded resources in the serializer should be serialized and which shouldn't, depending on the context. For instance, a serializer for posts may specify links for the normal CRUD action. However, it should probably only be possible to edit/delete a post if _current_user_ is the author of that post. This Policy will ensure that edit/delete links are hidden unless `current_user` is the author of the post:
```sh
class PostPolicy
  include HALPresenter::Policy::DSL

  link :edit, :'edit-form', :delete do
    current_user&.id == resource.author.id
  end
end
```
Here `resource` is the object being serialized (in our case the `post` object). Used together with a serializer that specifies links with rels _edit_, _edit-form_ and _delete_, this will only be serialize these links when the block returns `true`.  
Policies should also be used in Controllers (through the `authorize_with` class method). Since the links that should be serialized should coincide with which action should be allowed in the controller it makes sense to refactor this logic into a method.
```sh
  link :edit, :'edit-form', :delete do
    write?
  end

  def write?
    current_user&.id == resource.author.id
  end
```
Then the controller can call `authorize! :write` in the actions for editing/deleting and fetching of edit-form.

## Testing
Shaf helps you create `MiniTest::Spec`s for serializers and integration.

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
    attributes.keys.must_include(:foo)
    attributes.keys.must_include(:bar)
    attributes.keys.wont_include(:baz)
  end

  it "serializes links" do
    link_rels.must_include(:self)
    link_rels.must_include(:some_action)
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
      attributes.keys.must_include(:foo)
      attributes.keys.must_include(:bar)
      attributes.keys.wont_include(:baz)

      link_rels.must_include(:self)
      link_rels.must_include(:some_action)
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
      attributes.keys.must_include(:foo)
      attributes.keys.must_include(:bar)
      attributes.keys.wont_include(:baz)

      link_rels.must_include(:self)
      link_rels.must_include(:some_action)
    end
  end
end
```

#### Integration specs
Integration specs must pass in `{type: :integration}` as extra arguments to `describe`, such as `describe "Posts", type: :integration do; end`. This will include `Rack::Test::Methods`, `Shaf::UriHelper` and `Shaf::Spec::PayloadUtils`. The combination of the methods added by these modules gives integration specs a kind of [Capybara](https://github.com/teamcapybara/capybara) touch. Example:
```sh
require 'spec_helper'

describe "Post", type: :integration do
  it "can create posts" do
    get posts_uri

    embedded :'doc:create-form' do
      links[:self][:href].must_equal new_post_uri
      attributes[:href].must_equal posts_uri
      attributes[:method].must_equal "POST"
      attributes[:name].must_equal "create-post"
      attributes[:title].must_equal "Create Post"
      attributes[:type].must_equal "application/json"
      attributes[:fields].size.must_equal 1

      payload = fill_form attributes[:fields]
      post attributes[:href], payload
      status.must_equal 201
      link_rels.must_include(:self)
      headers["Location"].must_equal links[:self][:href]
    end

    get posts_uri
    status.must_equal 200
    links[:self][:href].must_include posts_uri
    embedded(:'posts').size.must_equal 1

    embedded :'posts' do
      post = last_payload.first
      post[:message].must_equal "value for message"
    end
  end
end
```
This spec will:
- start by fetching the posts_uri (e.g. `GET /posts`). This will call `set_payload(response)` behind the scenes.
- Verify that the response embeds a resource with rel `doc:create-form` with some speced attributes.
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

## API Documentation
Since API clients should basically only have to care about the payloads that are returned from the API, it makes sense to keep the API documentation in the serializer files. Each `attribute`, `link`, `curie` and `embed` should be preceeded with code comments that documents how client should interpret/use it. The comments should be in markdown format. This makes it possible to generate API documentation with `rake doc:generate`. This documentation can then be retrieved from a running server at `/doc/RESOURCE_NAME`, where `RESOURCE_NAME` is the name of the resource to fetch doc for, e.g `curl localhost:3000/doc/post`.

## Frontend
To make it easy to explore the API in a brower, Shaf includes a some very basic html views. They are only meant to be a quick and easy way to view the api and to add/edit resources that does not require authentication. They are really ugly and you should not look at them if you are a frontend developer ;) (PRs are welcome!).

## Customizations
Currently Shaf only support four commands (`new`, `server`, `console` and `generate`). Luckily it's possible to extend Shaf with custom commands and generators. Whenever the `shaf` command is executed the file `config/customize.rb` is loaded and checked for additional commands. To add a custom command, create a class that inherits from `Shaf::Command::Base`. Either put it directly in `config/customize.rb` or put it in a separate file and require that file inside `config/customize.rb`. Your customized class must call the inherited class method `identifier` with a `String`/`Symbol`/`Regexp` (or an array of `String`/`Symbol`/`Regexp` values) that _identifies_ the command. The identifier is used to match arguments passed to `shaf`. The command/generator must respond to `call` without any arguments. The arguments after the identifer will be availble from the instance method `args`. Writing a couple of simple command that echos back the arguments would be written as:
```sh
class EchoCommand < Shaf::Command::Base
  identifier :echo

  def call
    puts args
  end
end

class EchoUpCommand < Shaf::Command::Base
  identifier :echo, :up

  def call
    puts args.map(&:upcase)
  end
end

class EchoDownCommand < Shaf::Command::Base
  identifier :echo, :down

  def call
    puts args.map(&:downcase)
  end
end
```
Then running `shaf echo Hello World` would print:
```sh
Hello
World
```
Running `shaf echo up Hello World` would print:
```sh
HELLO
WORLD
```
Running `shaf echo down Hello World` would print:
```sh
hello
world
```
These commands are of course useless, but hopefully they give you an idea of what is happening.  
Generators work pretty much the same but they MUST inherit from `Shaf::Generator::Base`. Generators also inherits the following instance methods that may help generating files processed through erb:
- `template_dir`
- `read_template(file, directory = nil)`
- `render(template, locals = {})`
- `write_output(file, content)`  

Example:
```sh
class FooServiceGenerator < Shaf::Generator::Base
  identifier :foo

  def template_dir
    "generator_templates"
  end

  def call
    content = render("foo_service", {some_variables: "used_in_template"})
    write_output("api/services/foo_service.rb", content)
  end
end
```
This would require the file `generator_templates/foo_service.erb` to exist in the project root. Executing `shaf generate foo` would then read that template, process it through erb (utilizing any local variables given to `render`) and then create the output file `api/services/foo_service.rb`.

## Contributing
If you find a bug or have suggestions for improvements, please create a new issue on Github. Pull request are welcome!

## License
The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
