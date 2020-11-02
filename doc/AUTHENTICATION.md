## Authentication
Shaf uses a concept of _authenticators_ to handle authentication. Currently the only natively supported authentication scheme is Basic Auth.
However support for additional schemes may be added by creating new authenticator classes.
(Please consider contributing to Shaf if you write an authenticator that could be of use to others).
See [Customizations](CUSTOMIZATIONS.md) for info about creating authenticators.

#### Basic Auth
To setup authentication with Basic Auth, call the `restricted` class method on `Shaf::Authenticator::BasicAuth`. A 'realm' must be specified using the `realm` keyword argument and a block must be passed in. The block must accept the keyword arguments `user` and `password`.
The return value of the block will be returned from the `current_user` helper.
Depending on how you have configured your user model etc this block will look different. But as an example it should probably look something like this:
```ruby
Shaf::Authenticator::BasicAuth.restricted realm: 'api' do |user:, password:|
  return unless user && password
  password_hash = Digest::SHA256.hexdigest(password)
  User.where(username: user, password_hash: password_hash).first
end
```

Now controllers can require user to authenticate, e.g. `authenticate! realm: 'api'`.  

Sometimes resources can be seen by unauthenticated users, but might contain more attributes and/or links when a user has authenticated. (This is often true for the entry point of the api). In this case it's good practice to let clients know how to authenticate by using the _WWW-Authenticate_ header. This can either be done using the non-bang version, e.g `authenticate realm: 'api'`. Or using the `www_authenticate(realm: nil)` helper which also sets the _WWW-Authenticate_ header but without looking up the current user.  
If you only have one realm, then a default realm can be configured in the settings yml using the key `default_authentication_realm`. This will make these helper methods operate on the default realm and the `realm` keyword argument may then be left out.  
Note: The _WWW-Authenticate_ header is of course also set when a 401 response is returned.
