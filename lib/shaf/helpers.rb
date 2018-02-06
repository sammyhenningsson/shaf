require 'shaf/helpers/payload'
require 'shaf/helpers/json_html'
require 'shaf/helpers/paginate'
require 'shaf/helpers/session'

module Shaf
  def self.helpers
    [
      Payload,
      JsonHtml,
      Paginate,
      Session,
    ]
  end
end
