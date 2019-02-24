require 'shaf/helpers/cache_control'
require 'shaf/helpers/json_html'
require 'shaf/helpers/paginate'
require 'shaf/helpers/payload'
require 'shaf/helpers/http_header'

module Shaf
  def self.helpers
    [
      CacheControl,
      JsonHtml,
      Paginate,
      Payload,
      HttpHeader,
    ]
  end
end
