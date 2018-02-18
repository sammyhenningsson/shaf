# Shaf (Sinatra Hypermedia API Framework) Beta
Shaf is a framework for building hypermedia driven REST APIs. Its goal is to be like a lightweight version of `rails new --api` with hypermedia as a first class citizen. Instead of reinventing the wheel Shaf uses [Sinatra](http://sinatrarb.com/) and adds a layer of conventions similar to [Rails](http://rubyonrails.org/). It uses [Sequel](http://sequel.jeremyevans.net/) as ORM and [HALPresenter](https://github.com/sammyhenningsson/hal_presenter) for policies and serialization (which means that the mediatype being used is [HAL](http://stateless.co/hal_specification.html)).
Most APIs claiming to be RESTful completly lacks the concept of links and relies upon clients to construction urls to _known_ endpoints. Thoses APIs are missing some important concepts that Roy Fielding put together in is dissertation about REST. Having the server always returning payloads with links (hypermedia) makes the responsibilies more clear and allows for more robust implementations. Clients will then always know what actions are possible and not depending of which links are present in the server response. For example, there's no need for a client to try to place an order unless the server supplies the corresponding link for that action. Also if the server decides to move some resources to another location or change the access protocol (like https instead of http), this can be done without any changes to the client.
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

Currently your APIs is pretty useless. Let's fix that by generating some scaffolding.
```sh
shaf generate scaffold post title:string message:string 
Added:      api/models/post.rb
Added:      db/migrations/20180224225335_create_posts_table.rb
Added:      api/serializers/post_serializer.rb
Added:      spec/serializers/post_serializer_spec.rb
Added:      api/policies/post_policy.rb
Added:      api/controllers/posts_controller.rb
Added:      spec/integration/posts_controller_spec.rb
Modified:   api/serializers/root_serializer.rb
```
This will create a new model with two attributes (`title` and `message`) as well as a controller, a serializer and a policy. It will also generate a DB migration file, some specs and add a link to the new`post` collection in the root resource. So let's check this out by migrating the DB and restarting the server. Close any running instance with `Ctrl + C` and then:
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
This is the collection of posts (which currently is empty, see _'_embedded'_ => _'posts'_). Besides from the emtpy list of posts we also get an embedded form (with rel _doc:create-form_). This form should be used to create a new post.


## HAL
The [HAL](http://stateless.co/hal_specification.html) mediatype is very simple and looks like a any JSON object, except for two reserved keys __links_ and __embedded_. __links_ displays possible actions that may be taken. __embedded_ contains nested resources. A HAL payload may contain a special link with rel _curies_, which is similar to namespaces in XML. Shaf uses a curie called _doc_ and makes it possible to fetch documentation for any link or embedded resources with a rel begining with 'doc:'. The href for curies are always templated, meaning that a part of the href (in our case '{rel}') must be replaced with a value. In the payload above the href of the doc curie is 'http://localhost:3000/doc/post/rels/{rel}' and there is one embedded resource prefixed with 'doc:', namely 'doc:create-form'. So this means that if we would like to find out information about what this embedded resource is and how it relates to the posts collection we replace '{rel}' with 'create-form' and perform a GET request to this url.
```sh
curl http://localhost:3000/doc/post/rels/create-form
```
This documentation is written as code comments in the corresponding serializer. See [Serializers](#Serializers) for more info.  

## Generators
Shaf supports a few different generator to make it easy to create new files. Each generator has an _identifier_ and they are called with `shaf generate IDENTIFIER` plus zero or more arguments.

#### Scaffold
Shaf makes it easy to create new files with generators. When adding a new resource its recommended to use the scaffold generator. It accepts a resource name and an arbitrary number of attribute:type:label arguments.
```sh
shaf generate scaffold some_resource attr1:string attr2:integer
```
The scaffold generator will call the model generator and the controller generator.

#### Controller
A new controller is generated with the _controller_ identifier and a resource name and an arbitrary number of attribute:type:label arguments.
```sh
shaf generate controller some_resource attr1:string attr2:integer
```
This will add a new controller and an integration spec. It will also modify the root resource to include a link the the collection endpoint for _some_resource_.

#### Model
A new model is generated with the _model_ identifier and a resource name and an arbitrary number of attribute:type:label arguments.
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
    generate migration
    generate migration add column TABLE_NAME field:type
    generate migration create table TABLE_NAME [field:type] [..]
    generate migration drop column TABLE_NAME COLUMN_NAME
    generate migration rename column TABLE_NAME OLD_NAME NEW_NAME
See [the Sequel migrations documentation](http://sequel.jeremyevans.net/rdoc/files/doc/migration_rdoc.html) for more info.
Note: You can also add custom migrations, see [Customizations](#Customizations)

## Routing/Controllers
As usual with Sinatra applications routes are declared together with the controller code rather than in a separate file (like Rails). All controllers SHOULD be subclasses of `BaseController` found in `api/controllers/base_controller.rb` (which was created along with the project).  
TODO

## Models
Models generated with `shaf generate` inherits from `Sequel::Model` (see [Sequel](http://sequel.jeremyevans.net/documentation.html) for more info) and they include `Shaf::Formable`. The Formable module associates two forms with the model. One for creating a new resource and one for editing an extension resource. These forms contain an array of _fields_ that specifies all attributes that are accepted for create/update. When submitting the form it MUST be sent to the url in _href_ with the HTTP method specified in _method_ with the Content-Type header set to the value of _type_. TODO

## Serializers
TODO

## Policies
TODO

## Testing
TODO

## API Documentation
TODO

## Customizations
TODO

## Contributing
If you find a bug or have suggestions for improvements, please create a new issue on Github. Pull request are welcome!

## License
The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
