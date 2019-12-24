## Authentication
Shaf uses a concept of _authenticators_ to handle authentication. Currently the only natively supported authentication scheme is Basic Auth.
However support for additional schemes may be added by creating new authenticator classes.
(Please consider contributing to Shaf if you write an authenticator that could be of use to others)

#### HTTP authentication framework
TODO

#### Basic Auth
TODO

#### Creating new authenticators
All authenticators must be subclasses of `Shaf::Authenticator::Base`
TODO
