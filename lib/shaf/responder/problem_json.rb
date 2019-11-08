module Shaf
  module Responder
    class ProblemJson < Base
      mime_type :problem_json, 'application/problem+json'

      def self.can_handle?(resource)
        klass = resource.is_a?(Class) ? resource: resource.class
        klass <= StandardError
      end

      def body
        JSON.generate(hash)
      end

      private

      def hash
        {
          status: controller.status,
          type: code,
          title: title,
          detail: resource.message,
        }
      end

      def status
        return resource.http_status if resource.respond_to? :http_status
        controller.status
      end

      def code
        return resource.code if resource.respond_to? :code
        'about:blank'
      end

      def title
        return resource.title if resource.respond_to? :title
        resource.class.to_s
      end
    end
  end
end

