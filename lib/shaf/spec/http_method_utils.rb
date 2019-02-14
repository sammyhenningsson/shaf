module Shaf
  module Spec
    module HttpUtils
      include ::Rack::Test::Methods

      %i[get put patch post delete options head link unlink].each do |m|
        define_method m do |uri, payload = nil, options = {}|
          set_headers

          if payload
            payload = JSON.generate(payload) if payload.respond_to? :to_h
            options['CONTENT_TYPE'] ||= 'application/json'
            super(uri, payload, options)
          else
            super(uri, options)
          end

          set_payload parse_response(last_response.body)
        end
      end

      def status
        last_response&.status
      end

      def headers
        last_response&.headers || {}
      end
    end
  end
end
