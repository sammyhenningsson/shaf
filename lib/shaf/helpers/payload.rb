# frozen_string_literal: true

require 'set'
require 'shaf/responder'

module Shaf
  module Payload
    EXCLUDED_FORM_PARAMS = ['captures', 'splat'].freeze

    private

    def payload
      @payload ||= parse_payload
    end

    def read_input
      request.body.rewind unless request.body.pos.zero?
      request.body.read
    ensure
      request.body.rewind
    end

    def parse_payload
      if request.env['CONTENT_TYPE'] == 'application/x-www-form-urlencoded'
        return params.reject { |key, _| EXCLUDED_FORM_PARAMS.include? key }
      end

      input = read_input
      return {} if input.empty?

      raise raise_unsupported_media_type_error(request) unless suported_media_type?

      JSON.parse(input, symbolize_names: true)
    rescue Errors::UnsupportedMediaTypeError
      raise
    rescue StandardError => e
      raise Errors::BadRequestError, "Failed to parse input payload: #{e.message}"
    end

    def suported_media_type?
      request.env['CONTENT_TYPE'].match? %r{\Aapplication/(hal\+)?json}
    end

    def raise_unsupported_media_type_error(request)
      raise Errors::UnsupportedMediaTypeError.new(request: request)
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

    def ignore_form_input?(name)
      name == '_method'
    end

    def profile(value = nil)
      return @profile unless value
      @profile = value
    end

    def respond_with_collection(resource, status: nil, serializer: nil, **kwargs)
      respond_with(
        resource,
        status: status,
        serializer: serializer,
        collection: true,
        **kwargs
      )
    end

    def respond_with(resource, status: nil, serializer: nil, collection: false, **kwargs)
      status ||= resource.respond_to?(:http_status) ? resource.http_status : 200
      status(status)

      kwargs.merge!(
        profile: profile,
        serializer: serializer,
        collection: collection
      )

      log.info "#{request.request_method} #{request.path_info} => #{status}"
      payload = Responder.for(request, resource).call(self, resource, **kwargs)
      add_cache_headers(payload, kwargs)
      payload
    rescue StandardError => err
      log.error "Failure: #{err.message}\n#{err.backtrace}"
      if status == 500
        content_type mime_type(:json)
        body JSON.generate(failure: err.message)
      else
        respond_with(Errors::ServerError.new(err.message))
      end
    end

    def add_cache_headers(payload, kwargs)
      return unless kwargs.delete(:http_cache) { Settings.http_cache }
      return if payload.nil? || payload.empty?

      sha1 = Digest::SHA1.hexdigest payload
      etag sha1, :weak # Weak or Strong??
    end
  end
end
