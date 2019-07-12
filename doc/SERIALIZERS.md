## Serializers
Serializers generated with `shaf generate` inherits from `BaseSerializer` which extends `HALPresenter` and `Shaf::UriHelper`. This means that they have a clean DSL that makes it easy to specify what should be serialized. `Shaf::UriHelper` makes all uri helpers accessible. Serializing a message attribute and a self link is as simple as:
```sh
class PostSerializer < BaseSerializer

  attribute :message

  link :self do
    post_path(resource)
  end
end

post = OpenStruct.new(id: 5, message: "hello")
PostSerializer.to_hal(post) # This will return the following response:
# {
#   "message": "hello",
#   "_links": {
#     "self": {
#       "href": "/posts/5"
#     }
#   }
# }
```
This serializer will send `:message` to the object being serializer and set the returned value in the 'message' property. It will also add a link with rel _self_ and `href` set to the returned value of the corresponding block. `post_path` comes from `Shaf::UriHelper` and `resource` is a `HALPresenter` method that returns the resource being serialized. See [HALPresenter](https://github.com/sammyhenningsson/hal_presenter) for more information.  
This is also where the api should be documented. Each `attribute`/`link`/`curie`/`embed` directive should be preceeded with comments that document the corresponding usage. See [API Documentation](DOCUMENTATION.md) for more info.
