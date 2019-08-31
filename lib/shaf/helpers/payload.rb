# frozen_string_literal: true

require 'set'

module Shaf
  module Payload
    EXCLUDED_FORM_PARAMS = ['captures', 'splat'].freeze

    def supported_response_types(resource)
      [
        mime_type(:hal),
        mime_type(:json),
        mime_type(:html)
      ]
    end

    def preferred_response_type(resource)
      supported_types = supported_response_types(resource)
      request.preferred_type(supported_types)
    end

    def prefer_html?
      request.preferred_type.to_s == mime_type(:html)
    end

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

    def respond_with_collection(resource, status: 200, serializer: nil, **kwargs)
      respond_with(
        resource,
        status: status,
        serializer: serializer,
        collection: true,
        **kwargs
      )
    end

    def respond_with(resource, status: 200, serializer: nil, collection: false, **kwargs)
      status(status)

      preferred_response = preferred_response_type(resource)
      http_cache = kwargs.delete(:http_cache) { Settings.http_cache }

      serializer ||= HALPresenter.lookup_presenter(resource)
      serialized = serialize(resource, serializer, collection, **kwargs)
      add_cache_headers(serialized) if http_cache

      log.info "#{request.request_method} #{request.path_info} => #{status}"

      if preferred_response == mime_type(:html)
        respond_with_html(resource, serialized)
      else
        respond_with_hal(resource, serialized, serializer)
      end
    end

    def serialize(resource, serializer, collection, **options)
      if collection
        serializer.to_collection(resource, current_user: current_user, **options)
      else
        serializer.to_hal(resource, current_user: current_user, **options)
      end
    end

    def respond_with_hal(resource, serialized, serializer)
      log.debug "Response payload (#{resource.class}): #{serialized}"
      content_type :hal, content_type_params(serializer)
      body serialized
    end

    def respond_with_html(resource, serialized)
      log.debug "Responding with html. Output payload (#{resource.class}): #{serialized}"
      content_type :html
      case resource
      when Formable::Form
        body erb(:form, locals: {form: resource, serialized: serialized})
      else
        body erb(:payload, locals: {serialized: serialized})
      end
    end

    def add_cache_headers(payload)
      return if payload.nil? || payload.empty?

      sha1 = Digest::SHA1.hexdigest payload
      etag sha1, :weak # Weak or Strong??
    end

    def content_type_params(serializer)
      return {profile: profile} if profile

      {profile: serializer.semantic_profile}.compact
    end
  end
end
