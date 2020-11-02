## Policies
Policies generated with `shaf generate` inherits from `BasePolicy` which includes `HALPresenter::Policy::DSL`.
This means that they have a DSL that makes it easy to specify which attributes/links/embedded resources in the
serializer should be serialized and which shouldn't (e.g. depending on the context). See
[HALPresenter - Policy DSL](https://github.com/sammyhenningsson/hal_presenter#policy-dsl) for more info.
For example, a serializer for posts may specify links for the normal CRUD action.
However, it should probably only be possible to edit/delete a post if _current_user_ is the author of that post.
This Policy will ensure that edit/delete links are hidden unless `current_user` is the author of the post:
```sh
class PostPolicy < BasePolicy

  link :edit, :'edit-form', :delete do
    current_user&.id == resource.author.id
  end
end
```
Here `resource` is the object being serialized (in our case the `post` object). Used together with a serializer
that specifies links with rels _edit_, _edit-form_ and _delete_, those links will only be serialized when the
block above returns `true`. The `resource` method is inherited and general for all policies. To make this a bit prettier
it's recommended to create an alias for the name of the resource that the policy handles.
Policies should also be used in Controllers (through the `authorize_with` class method). Since the links that
should be serialized should coincide with which action should be allowed in the controller it makes sense to
refactor this logic into a method.
```sh
class PostPolicy < BasePolicy

  alias post resource

  link :edit, :'edit-form', :delete do
    write?
  end

  def write?
    current_user&.id == post.author.id
  end
end
```
Now the controller can call `authorize! :write, post` in the actions for editing/deleting and fetching of edit-form. This means we have a single method (`write?`) that controls both that we don't give out links to something a client cannot use as well as assuring that the corresponding controller actions are authorized correctly.

