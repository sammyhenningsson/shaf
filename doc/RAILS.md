## Rails

If you already have a web application in Rails, then you can mount a Shaf API inside Rails. This way you can reuse existing models and business logic and expose them through a REST API.

#### Create a new Shaf project
In your rails root, run  `shaf new rest`. This will create a new Shaf project inside `rest/`. You may of course name your Shaf project something else. The rest of this document assumes that the Shaf project is located in `Rails.root/rest`. So remember to replace rest with your project name if you choose to use a different name.

#### Move the Shaf runtime dependencies into Rails
The new rails project will have a Gemfile with dependencies for Shaf. Copy the gems from this Gemfile (e.g. `rest/Gemfile`) into the Gemfile in Rails. Then delete `rest/Gemfile`.

#### Mount the REST api inside Rails
To be able to mount a Shaf API, the corresponding search path must be added to the load path and the Shaf api must be booted. 
Then we can simply mount the Shaf API as rack application. These three things can be done by modifying `config/routes.rb` with the following changes:
```sh
--- a/config/routes.rb
+++ b/config/routes.rb
@@ -1,5 +1,12 @@
+$LOAD_PATH << File.expand_path('rest')
+Dir.chdir('rest') do
+  require 'config/bootstrap'
+end
+
 Rails.application.routes.draw do
   resources :posts
   resources :users
   # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
+
+  # Mount the Shaf REST API
+  mount Shaf::App => '/api'
 end
```

#### Fix the base path in Shaf
By default Shaf sets the API root to be `/`. Since the API is now mounted on `/api`, we need to update some controllers so that they are using /api as base.
These controllers are `rest/api/controllers/root_controller.rb` and `rest/api/controllers/docs_controller.rb`. This is how these changes should look:
```sh
--- a/rest/api/controllers/docs_controller.rb
+++ b/rest/api/controllers/docs_controller.rb
@@ -1,8 +1,8 @@
 class DocsController < BaseController

-  register_uri :profile,        '/doc/profiles/:name'
-  register_uri :doc_curie,      '/doc/profiles/:name{#rel}'
-  register_uri :documentation,  '/doc/:resource'
+  register_uri :profile,        '/api/doc/profiles/:name'
+  register_uri :doc_curie,      '/api/doc/profiles/:name{#rel}'
+  register_uri :documentation,  '/api/doc/:resource'

   before_action do
     cache_control(:private, http_cache_max_age: :long)
```

```sh
--- a/rest/api/controllers/root_controller.rb
+++ b/rest/api/controllers/root_controller.rb
@@ -1,6 +1,6 @@
 class RootController < BaseController

-  register_uri :root, '/'
+  register_uri :root, '/api'
```


#### Verify that things are working
Now Rails should be all set to expose your Shaf API. Run `rails server` in a terminal. From another terminal, fetch the API root, with `curl localhost:3000/api`


#### Create new resources
Typically you already have models in Rails that you want also use in the REST API. But lets create some files just to have an example. Add a Post resource using:
```sh
rails g scaffold post title:string message:string
rails db:migrate
rails runner 'Post.create(title: "hello", message: "world")'
```

Now lets add some Shaf stuff. First we need change into the API project directory, `cd rest`. Then generate a Shaf scaffold for posts
```sh
shaf g scaffold api/post title:string message:string --skip-model
```
Note: We need to put the Shaf classes in a namespace. Otherwise we will get collisions between classes in Rails and Shaf. (e.g. `PostsController` will exist in both).
Since we already have a model in Rails we skip generating a model in Shaf.

Now verify that things works as expected:
Restart rails (unfortunately autoloading wont work with Shaf), then verify that the post created earlier is showing up:
```sh
$> curl localhost:3000/api | jq
{
  "_links": {
    "self": {
      "href": "http://localhost:3000/api"
    },
    "posts": {
      "href": "http://localhost:3000/api/posts"
    }
  }
}

$> curl localhost:3000/api/posts | jq
{
  "_links": {
    "self": {
      "href": "http://localhost:3000/api/posts"
    },
    "up": {
      "href": "http://localhost:3000/api"
    },
    "create-form": {
      "href": "http://localhost:3000/api/post/form"
    },
    "curies": [
      {
        "name": "doc",
        "href": "http://localhost:3000/api/doc/profiles/api_post{#rel}",
        "templated": true
      }
    ]
  },
  "_embedded": {
    "posts": [
      {
        "title": "hello",
        "message": "world",
        "_links": {
          "profile": {
            "href": "http://localhost:3000/api/doc/profiles/api_post"
          },
          "collection": {
            "href": "http://localhost:3000/api/posts"
          },
          "self": {
            "href": "http://localhost:3000/api/posts/1"
          },
          "edit-form": {
            "href": "http://localhost:3000/api/posts/1/edit"
          },
          "doc:delete": {
            "href": "http://localhost:3000/api/posts/1"
          }
        }
      }
    ]
  }
}
```
#### Caveat
The mounted Shaf project is not aware of the port that rails is running on. It simply uses the configured port in (`rest/config/settings.yml`). So if rails would have been started with `rails server -p 4000`, then all api uri would point to the wrong port.
The solution to this is to either use the PORT environment variable, which is support by both Rails and Shaf. Or ensure that `rest/config/settings.yml` is configured with the correct port.
