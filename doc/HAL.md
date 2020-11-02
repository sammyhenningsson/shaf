## HAL
The [HAL](http://stateless.co/hal_specification.html) mediatype is very simple and looks like your ordinary JSON objects, except for two reserved keys `_links` and `_embedded`.  
`_links` displays links to related resources and possible actions that may be taken.  
`_embedded` contains nested resources. A HAL payload may contain a special link with rel _curies_, which is similar to namespaces in XML. Shaf uses a curie called _doc_ and makes it possible to fetch documentation for any link or embedded resources with a rel begining with `doc:`. The href for curies are always templated, meaning that a part of the href (in our case `{rel}`) must be replaced with a value. Here is the empty collection response from the [Getting started](README.md#getting-started) intro   
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
In the payload above the href of the _doc_ curie is `http://localhost:3000/doc/profiles/post{#rel}` and the delete link is prefixed with `doc:`. This means that if we would like to find out information about how the `doc:delete` link relates to the posts collection we replace `{rel}` with `delete` and perform a GET request to this url.
```sh
http://localhost:3000/doc/profiles/post#delete
```
As a human its quite easy to guess that the `doc:delete` relation means that we may delete the resource. However, for a client it might not be obvious. Luckily the response from the _GET_ request is formatted as a mediatype profile that describe what the link means. (E.g. clients can automatically know that they should send a _DELETE_ request to the href if this link relation should be activated.)
