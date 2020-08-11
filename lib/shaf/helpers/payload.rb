# frozen_string_literal: true

require 'set'
require 'shaf/responder'
require 'shaf/parser'

module Shaf
  module Payload
    NO_VALUE = Object.new.freeze

    private

    def payload
      return @payload if defined? @payload
      @payload = parse_payload
    end

    def parse_payload
      return unless Parser.input? request

      parser = Parser.for(request)
      raise Errors::UnsupportedMediaTypeError.new(request: request) unless parser

      log.debug "Parsing input using: #{parser.class}"
      parser.call
    rescue Parser::Error => e
      raise Errors::BadRequestError, "Failed to parse input payload: #{e.message}"
    end

    def safe_params(*fields)
      return {} unless payload

      fields = fields.map { |f| f.to_sym.downcase }.to_set
      fields << :id

      fields.each_with_object({}) do |f, allowed|
        allowed[f] = payload[f] if payload.key? f
        allowed[f] ||= payload[f.to_s] if payload.key? f.to_s
      end
    end

    def profile(value = NO_VALUE)
      return @profile if value == NO_VALUE
      @profile = value
    end

    def respond_with_collection(resource, status: nil, serializer: nil, preload: [], **kwargs)
      respond_with(
        resource,
        status: status,
        serializer: serializer,
        collection: true,
        preload: preload,
        **kwargs
      )
    end

    def respond_with(resource, status: nil, serializer: nil, collection: false, preload: [], **kwargs)
      status ||= resource.respond_to?(:http_status) ? resource.http_status : 200
      status(status)

      kwargs.merge!(serializer: serializer, collection: collection)
      kwargs[:profile] ||= profile

      log.info "#{request.request_method} #{request.path_info} => #{status}"
      payload = Responder.for(request, resource).call(self, resource, preload: preload, **kwargs)
      add_cache_headers(payload, kwargs)

      payload
    rescue StandardError => err
      log.error "Failure: #{err.message}\n#{err.backtrace}"
      if status == 500
        content_type mime_type(:json)
        body JSON.generate(failure: err.message)
      elsif err.is_a? Errors::ServerError
        respond_with(err)
      else
        respond_with(Errors::ServerError.new(err.message))
      end
    end

    def add_cache_headers(payload, kwargs)
      return unless kwargs.delete(:http_cache) { Settings.http_cache }

      chksum, kind = etag_for(payload)
      etag(chksum, kind: kind) if chksum
    end

    def etag_for(payload)
      return if payload.nil? || payload.empty?

      sha1 = Digest::SHA1.hexdigest payload
     [sha1, :weak] # Weak or Strong??
    end
  end
end
