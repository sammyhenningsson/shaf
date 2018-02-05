module Shaf
  module Payload
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
      return @payload if defined? @payload
      request.body.rewind
      @payload = parse(request.body.read)
    end

    def parse(payload)
      return if payload.empty?
      if request.env['CONTENT_TYPE'] == 'application/x-www-form-urlencoded'
        parse_urlencoded(payload)
      elsif request.env['CONTENT_TYPE'] =~ %r(\Aapplication/json)
        JSON.parse(payload)
      else
        raise ::UnsupportedMediaTypeError.new(request: request)
      end
    end

    def parse_urlencoded(payload)
      payload.split('&').each_with_object({}) do |field, h|
        k,v = field.split('=')
        h[k] = v unless ignore_form_input?(k)
      end
    end

    def safe_params(*fields)
      return {} unless payload
      {}.tap do |allowed|
        fields.each do |field|
          f = field.to_s.downcase
          allowed[f.to_sym] = payload[f] if payload[f]
        end
      end
    end

    def ignore_form_input?(name)
      return name == '_method'
    end

    def respond_with_collection(resource, status: 200, serializer: nil)
      respond_with(resource, status: status, serializer: serializer, collection: true)
    end

    def respond_with(resource, status: 200, serializer: nil, collection: false)
      status(status)

      preferred_response = preferred_response_type(resource)
      serialized = serialize(resource, serializer, collection)

      if preferred_response == mime_type(:html)
        respond_with_html(resource, serialized)
      else
        respond_with_hal(resource, serialized)
      end
    end

    def serialize(resource, serializer, collection)
      serializer ||= HALPresenter
      if collection
        serializer.to_collection(resource, current_user: current_user)
      else
        serializer.to_hal(resource, current_user: current_user)
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
      when Shaf::Formable::Form
        body erb(:form, locals: {form: resource, serialized: serialized})
      else
        body erb(:payload, locals: {serialized: serialized})
      end
    end

  end
end
