require 'shaf/helpers/payload'
require 'shaf/helpers/json_html'
require 'shaf/helpers/paginate'

module Shaf
  def self.helpers
    [
      Payload,
      JsonHtml,
      Paginate,
    ]
  end
end
