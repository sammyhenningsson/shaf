## Forms
Shaf uses forms for creating and editing resources. Forms makes it easy to evolve your API, by letting clients know how to create/edit resources. It also allows for clients to validate forms before submitting them and they are well suited for HTTP caching (since they normally wont change very often, cached entries will be fresh for a long time).

Forms are created by extending `Shaf::Formable`. The Formable module adds the class method `forms_for` which builds form clases. These form instances can then be accessed from the class passed as argument to `::forms_for`. By default, shaf generates two forms per resource, one for creating new resources and one for editing existing resources. However, as many as needed can easily be added.  
As an example, the following class will add the standard create and update forms to the `User`class. The create form will have fields `foo` and `bar` The edit form will have fields `foo` and `baz`.
```ruby
class UserForms
  extend Shaf::Formable

  forms_for(User) do
    field :foo, type: "string" # common field

    create do
      # These properties are only for the create form
      title 'Create User'
      name  'create-user'
      field :bar, type: "string"
    end

    edit do
      instance_accessor

      # These properties are only for the edit form
      title 'Update User'
      name  'update-user'
      field :baz, type: "integer", accessor_name: :instance_method_returning_baz
    end
  end
end
```
This will create two instances of `Shaf::Formable::Form` which will be accessible from the `User` class, e.g `User.create_form` resp. `User.edit_form`. Forms with `instance_accessor` will also be retrievable from instances, e.g. `User[5].edit_form`.
By default, forms retreived from instances will be prefilled with values from the instance (to change this, pass `prefill: false` to `instance_accessor`).  
Fields are filled with values retreived by calling an instance method of the same name as the field name. If the name of the form field does not match the corresponding instance method on the model, then pass the name of the model instance method that should be called to the `accessor_name` keyword argument when declaring the field. In the example above, the edit form will have the `:foo` field prefilled with a value like `User[5].foo` and the `:baz` field will be prefilled with the return value of `User[5].instance_method_returning_baz`.  

#### Interacting with forms
When serialized these forms contain an array of _fields_ that specifies all attributes accepted for create/update. Each field has a `name` property that must be used as key when constructing a payload to be submitted. Each field also has a type which declares the kind of value that are accepted (currently only string and integer are supported).
Optionally each field may specify the following keyword_arguments:
 - `title` - Meant to be displayed in a UI
 - `value` - An initial value. Normally set on an instance (e.g. `some_form[:field_with_value].value = "some_value"`)
 - `required` - Let clients know that this field must be submitted.
 - `hidden` - Let clients know that this field should not shown in a UI.

See [the shaf-form media type profile](https://gist.github.com/sammyhenningsson/39c8aafeaf60192b082762cbf3e08d57) for more info.

Clients submitting the form must send it to the url in `href` with the HTTP method specified in `method` with the Content-Type header set to the value of `type`. Here's the create form from the [Getting started](/README.md#getting-started) section.
```sh
    "create-form": {
      "method": "POST",
      "name": "create-post",
      "title": "Create Post",
      "href": "/posts",
      "type": "application/json",
      "_links": {
        "self": {
          "href": "http://localhost:3000/post/form"
        },
        "profile": {
          "href": "https://gist.githubusercontent.com/sammyhenningsson/39c8aafeaf60192b082762cbf3e08d57/raw/shaf-form.md"
        }
      },
      "fields": [
        {
          "name": "title",
          "type": "string",
        },
        {
          "name": "message",
          "type": "string",
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

To add more forms, simply add more form blocks inside the block passed to `forms_for`. For example, say that you would like to have a form for sending text messages to a user then perhaps something like this is a good start.

```ruby

class UserForms
  extend Shaf::Formable

  forms_for(User) do

    ...

    send_sms do
      instance_accessor
      title 'Send text message'
      name  'send-sms'
      field :message, type: "string"
      field :user_id, type: "integer", hidden: true, accessor_name: :id
    end
  end
end
```
The sms form can then be retrieved either from the `User` class (i.e. `User.send_sms_form`) or from an instance of `User` (i.e. `User[1].send_sms_form`). In the latter case the `user_id` field will be prefilled with the `id` of the corresponding user.

Note that forms do not specify a target href nor a HTTP method, which of course is required to make use of them. This is because that's the responsibility of the Controller. Thus the corresponding controller action typically has code like this:

```ruby
    def edit_form
      user.edit_form.tap do |form|
        form.self_link = edit_user_uri(user)
        form.href = user_uri(user)
        form.method = 'PUT'
      end
    end
```
