## HAL
The [HAL](http://stateless.co/hal_specification.html) mediatype is very simple and looks like your ordinary JSON objects, except for two reserved keys `_links` and `_embedded`.  
`_links` displays links to related resources and possible actions that may be taken.  
`_embedded` contains nested resources. A HAL payload may contain a special link with rel _curies_, which is similar to namespaces in XML. Shaf uses a curie called _doc_ and makes it possible to fetch documentation for any link or embedded resources with a rel begining with `doc:`. The href for curies are always templated, meaning that a part of the href (in our case `{rel}`) must be replaced with a value. Here is the empty collection response from the [Getting started](README.md#getting-started) intro   
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
    "doc:author": {
      "href": "http://localhost:3000/users/1"
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
    "posts": []
  }
}
```
In the payload above the href of the _doc_ curie is `http://localhost:3000/doc/post/rels/{rel}` and the author link is prefixed with `doc:`. This means that if we would like to find out information about how the `doc:author` link relates to the posts collection we replace `{rel}` with `author` and perform a GET request to this url.
```sh
curl http://localhost:3000/doc/post/rels/author
```
This documentation is written as code comments in the corresponding serializer. See [Serializers](SERIALIZERS.md) for more info. Before this documentation can be fetched, a rake task to extract the comments needs to be executed, see [API Documentation](DOCUMENTATION.md) for more info.  
HAL supports profiles that describes the semantic meaning if of keys/values. Shaf takes advantage of this and uses two profiles. One for describing generic error messages (see [shaf-error media type profile](https://gist.github.com/sammyhenningsson/049d10e2b8978059cde104fc5d6c2d52)) and another for describing forms (see [shaf-form media type profile](https://gist.github.com/sammyhenningsson/39c8aafeaf60192b082762cbf3e08d57)).  
