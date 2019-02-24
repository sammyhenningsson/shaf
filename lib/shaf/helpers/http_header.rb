require 'shaf/errors'

module Shaf
  module HttpHeader
    def request_headers
      unless respond_to? :request
        log.error <<~ERROR


          Classes including the HttpHeader module must respond to #request
          HttpHeader#request_headers called from #{self}.
        ERROR
        raise Errors::ServerError, 'Server bug'
      end

      request.env.each_with_object({}) do |(key, value), headers|
        next unless key =~ /^HTTP_/
        headers[key[5..-1].tr('_', '-')] = value
      end
    end

    def request_header(header)
      request_headers[header.to_s.upcase]
    end
  end
end
