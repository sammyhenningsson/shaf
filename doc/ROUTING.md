## Routing/Controllers
As usual with Sinatra applications routes are declared together with the controller code rather than in a separate file (as with Rails). All controllers should be subclasses of `BaseController` found in `api/controllers/base_controller.rb` (which was created along with the project).  
Controllers generated with `shaf generate` uses a few Sinatra extensions, where the most important are `Shaf::ResourceUris`, `Shaf::ControllerHooks` and `Shaf::Authorize`.

### Shaf::ResourceUris
This extension is used to create _uri_-/_path_ helpers. When registered with Sinatra (which is done in the generated `BaseController`) it adds two class methods, `resource_uris_for` and `register_uri`. The former adds four conventional uris (basically the CRUD actions). The later adds a single helper, for more custom actions.  
Each helper, created by `resource_uris_for` or `register_uri`, will be added as an instance method and a module method to the module `Shaf::UriHelper`. This means that they can be accessed from any file in your API through the module. Or by including/extending `Shaf::UriHelper` into a class.  
When included the module is also extended so all _uri_-/_path_ helpers will be available in the class as well. Also, the class that calls `resource_uris_for` or `register_uri` will automatically include `Shaf::UriHelper`, i.e. controllers registering new helpers will have access to the helper methods from instances and the class.  
##### `::resource_uris_for(name, base: nil, plural_name: nil)`
This method creates four pairs of uri helpers and adds them as class methods and instance methods to the caller. 
The keyword argument `:base` is used to specify a path namespace (such as '/api') that will be prepended to the uri. This can also be used to nest resources (though this is in general considered bad), like `resource_uris_for :post, base: '/users/:id/'`.  
The keyword argument `:plural_name` sets the pluralization of the name (when excluded the plural name will be `name` + 's').  
```sh
class PostsController < BaseController
  resource_uris_for :post
end
```
This adds four helpers for the conventional four CRUD actions. Each one has a __uri_ and a __path_ version. The `PostsController` above would create these methods:

| Method                                  | Example of returned strings (no query_params given) | 
| --------------------------------------- | --------------------------------------------------- |
| `posts_uri(**query_params)`             | http://localhost/posts                          |
| `post_uri(post, **query_params)`        | http://localhost/posts/5                        |
| `new_post_uri(**query_params)`          | http://localhost/post/form                      |
| `edit_post_uri(post, **query_params)`   | http://localhost/posts/5/edit                   |
| `posts_path(**query_params)`            | /posts                                          |
| `post_path(post, **query_params)`       | /posts/5                                        |
| `new_post_path(**query_params)`         | /post/form                                      |
| `edit_post_path(post, **query_params)`  | /posts/5/edit                                   |

Methods taking an argument (e.g. `post_uri` and `edit_post_uri`) may be called with an object responding to `:id` or else `:to_s` will be called on it. E.g `post_uri(Post[27])` or `post_uri(27)`.  
The optional `query_params` takes any given keyword arguments and appends a query string with them.  
```sh
  post_path(post, foo: 'bar')    #  => /posts/5?foo=bar
```
Each helper also has a __path?_ version that can be used to check if a path matches the one of the helper. If given an argument it is matched against the helpers path else the caller must respond to `request` (returning an object responding to `path_info`). Use cases
```sh
UriHelper.post_path?  "/posts/"     # => false
UriHelper.post_path?  "/posts/5"    # => true
```
Or
```sh
class PostsController < BaseController
  resource_uris_for :post

  before do
    setup_stuff
    setup_more_stuff_before_edit if edit_post_path?
  end

  …
end
```
If all four paths are not needed, some of them can (and should) be excluded using the keyword arguments `:only` or `:except`. The values passed to them must be a symbol or an Array of symbols from `[:new, :edit, :resource, :collection]`. Example:
```sh
class PostsController < BaseController
  resource_uris_for :post, only: :resource
end

PostsController.path_helpers     # => [:post_path]

class BooksController < BaseController
  resource_uris_for :book, except: [:edit, :collection]
end

BooksController.path_helpers     # => [:book_path, :new_book_path]
```

##### `::register_uri(name, uri)`
This method is used to create a single uri helper that does not follow the "normal" conventions of `resource_uris_for`.
```sh
class PostsController < BaseController
  register_uri :archive_post, '/posts/:id/archive'
end
```
This adds the helper method `archive_post_uri(post, **query_params)` (plus the __path_ and the __path?_ methods). Each parameter in the uri template (section begining with ':', e.g. _:some_param_) will become a parameter in the helper method. The correponding argument will get sent the paramter name if it respond to it, else `to_s` will be sent with the argument as receiver. An example will make things more clear:
```sh
class FooController < BaseController
  register_uri :foo_bar, '/:foo/hello/:bar/:baz'
end

obj1 = OpenStruct.new(foo: "FOOO")
obj2 = OpenStruct.new(bar: 1337)
obj3 = OpenStruct.new(baz: 'BAAAZA')
Shaf::UriHelper.foo_bar_path(obj1, obj2, 'BAZZZZ') # => /FOOO/hello/1337/BAZZZZ
Shaf::UriHelper.foo_bar_path('FOOZA', obj2, obj3) # => /FOOZA/hello/1337/BAAAZA
```
The helper above takes three arguments (since there's three sections begining with ':'). In the first call to `foo_bar_path` we pass in two objects responding to `:foo` resp. `:bar`, thus `obj1.foo` resp. `obj2.bar` is what ends up in the corresponding uri sections. The third argument does not respond to `:baz`, thus `to_s` is sent instead. The second call to `foo_bar_path` is just to clearify that we can call this helper in many ways.  

To make it easier to see the connection between controller routes and uri helpers, Shaf makes it possible to specify routes with symbols. These symbols must be the same as the __path_ version of the corresponding uri helper:
```sh
class PostsController < BaseController
  register_uri :archive_post '/posts/:id/archive'

  post :archive_post_path do
    "Post was archived!"
  end
end
```

#### Listing routes
Use the `routes` rake task to list all routes in the api. E.g:
```sh
$ rake routes

DocsController:
  doc_curie_path                                    GET                           /doc/:resource/rels/{rel}
  documentation_path                                GET                           /doc/:resource

PostsController:
  edit_post_path                                    GET                           /posts/:id/edit
  new_post_path                                     GET                           /post/form
  post_path                                         GET | PUT | DELETE            /posts/:id
  posts_path                                        GET | POST                    /posts

RootController:
  root_path                                         GET                           /

```

### Shaf::ControllerHooks
This extension adds a two hooks to run before or after a request. Sinatra already has the `before` and `after` filters, which are great if you want them to run before/after all routes. But if you want a filter to kick in for just some routes, then there are prettier ways of doing this. `Shaf::ControllerHooks` (which is registered in the generated `BaseController`) adds the `before_action` and `after_action` filters. They are used together with uri helpers so that we don't have to care about building some Regexp to make the filter apply only to a few routes. Example:
```sh
class PostsController < BaseController
  resource_uris_for :post

  before_action :setup_index, only: posts_path

  before_action only: [:new_post_path, :edit_post_path] do
    # Do some form setup
  end

  def setup_index
    # some setup
  end
end
```
These methods either take a symbol to an instance methods as first argument or a block as the action to be executed. The optional keyword arguments `:only` and `:except` may be used to target just certain routes. When both `:only` and `:exept` are left out, then the action applies to all routes within the given controller.

### Shaf::Authorize
This extension adds the class method `authorize_with(policy)` and the instance method `authorize!(action, resource = nil)`. The class method is used to register a Policy class. The instance method is used to ensure that a certain action is authorized. The following policy class makes sure that a user is logged in to be able to see posts and that users may only edit their own posts. See [Policies](POLICIES.md) for more info.
```sh
class PostPolicy < BasePolicy
  alias post resource

  def show?
    !!current_user
  end

  def edit?
    current_user && current_user.id == post.author.id
  end
end
```
The following controller validates actions using the `PostPolicy`. If the policy rejects the action, then a "403 Forbidden" is returned.
```sh
class PostsController < BaseController
  resource_uris_for :post

  authorize_with PostPolicy

  get :post_path do
    authorize! :show

    respond_with post 
  end

  put :edit_post_path do
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
After a policy class has been registered with `::authorize_with` then a call to `#authorize!` will create an instance of the policy with `current_user` and `resource` as arguments. Thus in the controller above, when a `GET` request is made to `post_uri` a policy instance will be created with `PostPolicy.new(current_user, nil)`. The `PUT` action will create the instance `PostPolicy.new(current_user, post)`. Then the arguments first argument sent to `#authorize!` will be sent (with an appended question mark unless already present) to the policy instance together with an optional argument. Like `policy.show?` resp. `policy.edit?`. So it's important to think about which policy rules should apply to a specific resource or should be a general rule (e.g. viewing a collection) where a specific resource is not present. 
Note: that the Policy instance methods must end with a question mark '?' while the symbol given to `authorize!` may or may not end with a question mark.  

### Rendering responses
Shaf controllers includes two helper methods that simplifies rendering responses:
- `respond_with(resource, status: 200, serializer: nil)`
- `respond_with_collection(resource, status: 200, serializer: nil)`

Given that you have a Serializer that is registered to process instances of `Post` (see [Serializers](SERIALIZERS.md) for more info), then a controller route may simply end with `respond_with post` (as shown above) and the response payload will be serialized as expected. Use the keyword arguments, `status` and `serializer`, if you would like to override the default http response code resp. the serializer to be used.

Link preloads can be added by passing the `preload` keyword argument to `#respond_with` and `#respond_with_collection`. The value must be a `Symbol` or and array of `Symbol`s with the link rels that should be preloaded. Like: `respond_with(resource, status: 200, preload: :author)`. This will extract the href of the link with rel `author` and add a Link preload to the response. For example:
```sh
curl -I https://my.shaf.api/

HTTP/1.1 200 OK
Content-Type: application/hal+json
Vary: X-User,Accept-Encoding
Cache-Control: private, max-age=86400
Link: </users/5>; rel=preload; as=fetch; crossorigin=anonymous
ETag: W/"cc0cd5e786525f3ce721992dbe00f67086e94f43"
Content-Length: 147
```

This means that if you run Shaf behind Nginx and your clients can speak HTTP2, then Nginx (if configured to do so) will push resources to the client, which greatly improves performance.
