# Shaf (Sinatra Hypermedia API Framework)
[![Gem Version](https://badge.fury.io/rb/shaf.svg)](https://badge.fury.io/rb/shaf)
![CI](https://github.com/sammyhenningsson/shaf/workflows/CI/badge.svg)  
Shaf is a framework for building hypermedia driven REST APIs. Its goal is to be like a lightweight version of `rails new --api` with hypermedia as a first class citizen. Instead of reinventing the wheel Shaf uses [Sinatra](http://sinatrarb.com/) and adds a layer of conventions similar to [Rails](http://rubyonrails.org/). It uses [Sequel](http://sequel.jeremyevans.net/) as ORM and [HALPresenter](https://github.com/sammyhenningsson/hal_presenter) for policies and serialization (which means that the main mediatype is [HAL](http://stateless.co/hal_specification.html)).  
Most APIs claiming to be RESTful completly lacks the concept of links and relies upon clients to construction urls to _known_ endpoints. Thoses APIs are missing some of the concepts that Roy Fielding put together in is dissertation about REST.  
If you don't have full understanding of what REST is then that's fine. Though you are encouraged to read up on the basics. Check out [this blog](https://apisyouwonthate.com/blog/rest-and-hypermedia-in-2019) for a great explanation of the building blocks of REST.  
A short version is: REST was "invented" by describing how the web is architectured. Web components (e.g browsers, servers, cache proxies etc) all use the same interface, where URIs and mediatypes play a big part. This enables any browser to connect to any web server without prior knowledge about each other. An important part of this is to use hypermedia links, which makes it possible for components to evolve independently.

Building a REST API requires knowledge about standards and a lot of boring stuff. Shaf aims to reduce those prerequirements, minimize bikeshedding and to get you up and running quickly. Some of the benefits of using Shaf is that you get:
 - Scaffolding
 - Serialization
 - Authorization
 - Content negotiation
 - Documentation
 - Forms
 - Uri helpers
 - Pagination
 - Testing
 - HTTP caching
 - Link preloading (enables HTTP2 Push)

## What's unique about Shaf?
The list above could be implemented in any web framework. So why use Shaf? Well, if you are comfortable writing it yourself, then perhaps Shaf might not be for you. However it can still be nice to have some conventions to rely upon, instead of having to decide all basic details. Like choosing a mediatype for instance (this is something people have very strong/different opinions about).  
I don't think there's another Ruby web framework that emphasizes the principles of REST as much as Shaf does.
An example of a unique feature (AFAIK) is that mediatypes are separated from controller actions. In most other frameworks, each controller action specifies the possible content type to be returned.
In Shaf, controller actions returns Ruby objects. Depending on what clients want to receive (specified by the `Accept` header),
the appropriate serializer is looked up and used to respond with the right representation. (This is not 100% true, since there's actually a helper, `respond_with`, that produces the usual `[status_code, headers, response]`. However you would still see it as an object being returned and serialization takes place afterwards. Parsing inputs is done using a similar approach.  
The most unique feature is probably the usage of mediatype profiles, which are used both for machine readable definitions and for generating documentation.(See [Mediatype profiles](doc/PROFILES.md) for more information.)

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
│   ├── policies
│   │   └── base_policy.rb
│   └── serializers
│       ├── base_serializer.rb
│       ├── documentation_serializer.rb
│       ├── error_serializer.rb
│       ├── form_serializer.rb
│       ├── root_serializer.rb
│       └── validation_error_serializer.rb
├── config
│   ├── bootstrap.rb
│   ├── customize.rb
│   ├── database.rb
│   ├── database.yml
│   ├── directories.rb
│   ├── helpers.rb
│   ├── initializers
│   │   ├── authentication.rb
│   │   ├── db_migrations.rb
│   │   ├── hal_presenter.rb
│   │   ├── logging.rb
│   │   └── sequel.rb
│   ├── initializers.rb
│   ├── paths.rb
│   └── settings.yml
├── config.ru
├── frontend
│   ├── assets
│   │   └── css
│   │       └── main.css
│   └── views
│       ├── form.erb
│       ├── headers.erb
│       ├── layout.erb
│       └── payload.erb
├── Gemfile
├── Gemfile.lock
├── Rakefile
└── spec
    ├── integration
    │   └── root_spec.rb
    ├── serializers
    │   └── root_serializer_spec.rb
    └── spec_helper.rb
```
You now have a functional API. Start the server with
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
curl command to `jq` (which is a great a tool for dealing with json strings).
```sh
curl localhost:3000/ | jq
```
Or if you don't have `jq` installed, you can also pretty print json through Ruby. E.g:
```sh
curl localhost:3000/ | ruby -rjson -e "puts JSON.pretty_generate(JSON.parse(STDIN.read))"
```

The project also contains a few specs that you can run with `rake`
```sh
shaf test
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
Added:      api/profiles/post.rb
Added:      api/forms/post_forms.rb
Added:      api/controllers/posts_controller.rb
Added:      spec/integration/posts_controller_spec.rb
Modified:   api/serializers/root_serializer.rb
```
As shown in the output, that command created, a model, a controller, a serializer and a policy. It also generated a DB migration file, some forms, some specs and a link to the new `post` collection was added the root resource. So let's check this out by migrating the DB and restarting the server. Close any running instance with `Ctrl + C` and then:
```sh
rake db:migrate
shaf server
```
Again in another terminal run
```sh
curl localhost:3000/ | jq
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
The root payload should now contain a link with rel _posts_. Lets follow that link..
```sh
curl localhost:3000/posts | jq
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
    "create-form": {
      "href": "http://localhost:3000/post/form"
    },
    "curies": [
      {
        "name": "doc",
        "href": "http://localhost:3000/doc/profiles/post{#rel}",
        "templated": true
      }
    ]
  },
  "_embedded": {
    "posts": []
  }
}
```
This is the collection of posts (which currently is empty, see `$response['_embedded']['posts']`). Notice the link with rel _create-form_. This is the api telling us that we may add new post resources. Let's follow that link!
```sh
curl http://localhost:3000/post/form | jq
```
The response looks like this
```sh
{
  "method": "POST",
  "name": "create-post",
  "title": "Create Post",
  "href": "http://localhost:3000/posts",
  "type": "application/json",
  "submit": "save",
  "_links": {
    "profile": {
      "href": "http://localhost:3000/doc/profiles/shaf-form"
    },
    "self": {
      "href": "http://localhost:3000/post/form"
    },
    "curies": [
      {
        "name": "doc",
        "href": "http://localhost:3000/doc/profiles/shaf-form{#rel}",
        "templated": true
      }
    ]
  },
  "fields": [
    {
      "name": "title",
      "type": "string"
    },
    {
      "name": "message",
      "type": "string"
    }
  ]
}
```
This form shows us how to create new post resources (see [Forms](doc/FORMS.md) for more info). A new post resource can be created with the following request 
```sh
curl -H "Content-Type: application/json" \
     -d '{"title": "hello", "message": "lorem ipsum"}' \
     localhost:3000/posts | jq
```
The response shows us the new resource, with the attributes that we set as well as links for updating and deleting it.
```sh
{
  "title": "hello",
  "message": "lorem ipsum",
  "_links": {
    "profile": {
      "href": "http://localhost:3000/doc/profiles/post"
    },
    "collection": {
      "href": "http://localhost:3000/posts"
    },
    "self": {
      "href": "http://localhost:3000/posts/1"
    },
    "edit-form": {
      "href": "http://localhost:3000/posts/1/edit"
    },
    "doc:delete": {
      "href": "http://localhost:3000/posts/1"
    },
    "curies": [
      {
        "name": "doc",
        "href": "http://localhost:3000/doc/profiles/post{#rel}",
        "templated": true
      }
    ]
  }
}
```
This new resource is of course added to the collection of posts, which can now be retrieved by the link with rel _collection_.
```sh
curl localhost:3000/posts | jq
```
Response:
```sh
{
  "_links": {
    "self": {
      "href": "http://localhost:3000/posts?page=1&per_page=25"
    },
    "up": {
      "href": "http://localhost:3000/"
    },
    "create-form": {
      "href": "http://localhost:3000/post/form"
    },
    "curies": [
      {
        "name": "doc",
        "href": "http://localhost:3000/doc/profiles/post{#rel}",
        "templated": true
      }
    ]
  },
  "_embedded": {
    "posts": [
      {
        "title": "hello",
        "message": "lorem ipsum",
        "_links": {
          "profile": {
            "href": "http://localhost:3000/doc/profiles/post"
          },
          "collection": {
            "href": "http://localhost:3000/posts"
          },
          "self": {
            "href": "http://localhost:3000/posts/1"
          },
          "edit-form": {
            "href": "http://localhost:3000/posts/1/edit"
          },
          "doc:delete": {
            "href": "http://localhost:3000/posts/1"
          }
        }
      }
    ]
  }
}
```

#### Recap
We have built a very basic hypermedia driven API with only one type of resource. The neatest thing about this is that it only took four commands:
```sh
shaf new blog
bundle
shaf generate scaffold post title:string message:string 
rake db:migrate
```

## Documentation
### [Sinatra](doc/SINATRA.md)
### [HAL mediatype](doc/HAL.md)
### [Mediatype profiles](doc/PROFILES.md)
### [Generators](doc/GENERATORS.md)
### [Routing/Controllers](doc/ROUTING.md)
### [Models](doc/MODELS.md)
### [Forms](doc/FORMS.md)
### [Serializers](doc/SERIALIZERS.md)
### [Policies](doc/POLICIES.md)
### [Authentication](doc/AUTHENTICATION.md)
### [Settings](doc/SETTINGS.md)
### [Database](doc/DATABASE.md)
### [Mediatype profiles](doc/PROFILES.md)
### [API Documentation](doc/DOCUMENTATION.md)
### [HTTP Caching](doc/HTTP_CACHING.md)
### [Pagination](doc/PAGINATION.md)
### [Upgrading a shaf project](doc/UPGRADE.md)
### [Testing](doc/TESTING.md)
### [ShafClient](doc/SHAF_CLIENT.md)
### [Frontend](doc/FRONTEND.md)
### [Customizations](doc/CUSTOMIZATIONS.md)
### [Business logic](doc/BUSINESS_LOGIC.md)


## Contributing
If you find a bug or have suggestions for improvements, please create a new issue on Github. Pull request are welcome!

## License
The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
