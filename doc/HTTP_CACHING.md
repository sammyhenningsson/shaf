## HTTP Caching
REST is a very chatty architecture. Fortunately it works very well with HTTP Caching. Resources that are unlikely to be changed often, such as the root resource, forms, documentation etc, will by default set the HTTP Header Cache-Control with a max-age (meant to be tweeked to a value that suites your api) to one day. Clients should respect this and cache those resources accordingly.
Each time a response is sent from the api the Etag header is set (with a weak Etag). Clients should make use of this and be able to handle a '304 Not Modified' response.
For more info check out [this page](https://developers.google.com/web/fundamentals/performance/optimizing-content-efficiency/http-caching) by Ilya Grigorik.
