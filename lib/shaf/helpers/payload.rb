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
      @@request_id ||= nil
      @@payload ||= nil

      if @@request_id != request.env["REQUEST_ID"]
        @@request_id = request.env["REQUEST_ID"]
        @@payload = parse_payload
      end
      @@payload
    end

    def read_input
      request.body.rewind unless request.body.pos == 0
      request.body.read
    ensure
      request.body.rewind
    end

    def parse_payload
      if request.env['CONTENT_TYPE'] == 'application/x-www-form-urlencoded'
        return params.reject { |key,_| EXCLUDED_FORM_PARAMS.include? key }
      end

      input = read_input
      return {} if input.empty?

      if request.env['CONTENT_TYPE'] =~ %r(\Aapplication/(hal\+)?json)
        JSON.parse(input)
      else
        raise ::UnsupportedMediaTypeError.new(request: request)
      end
    rescue StandardError
      raise ::BadRequestError.new
    end

    def safe_params(*fields)
      return {} unless payload

      field_strings = fields.map { |f| f.downcase.to_sym }.to_set
      field_strings << :id

      {}.tap do |allowed|
        field_strings.each do |f|
          allowed[f.to_sym] = payload[f] if payload.key? f
          allowed[f.to_sym] ||= payload[f.to_s] if payload.key? f.to_s
        end
      end
    end

    def ignore_form_input?(name)
      return name == '_method'
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

      serialized = serialize(resource, serializer, collection, **kwargs)
      add_cache_headers(serialized) if http_cache

      log.info "#{request.request_method} #{request.path_info} => #{status}"

      if preferred_response == mime_type(:html)
        respond_with_html(resource, serialized)
      else
        respond_with_hal(resource, serialized)
      end
    end

    def serialize(resource, serializer, collection, **options)
      serializer ||= HALPresenter
      if collection
        serializer.to_collection(resource, current_user: current_user, **options)
      else
        serializer.to_hal(resource, current_user: current_user, **options)
      end
    end

    def respond_with_hal(resource, serialized)
      log.debug "Response payload (#{resource.class}): #{serialized}"
      content_type :hal
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
  end
end
