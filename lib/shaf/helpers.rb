require 'shaf/helpers/cache_control'
require 'shaf/helpers/json_html'
require 'shaf/helpers/paginate'
require 'shaf/helpers/payload'

module Shaf
  def self.helpers
    [
      CacheControl,
      JsonHtml,
      Paginate,
      Payload,
    ]
  end
end
