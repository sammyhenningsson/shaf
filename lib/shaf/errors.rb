module Shaf
  class Error < StandardError; end

  module Errors
    class ServerError < Error
      attr_reader :code, :title

      def http_status
        500
      end

      def initialize(msg = "Unknown error", code: nil, title: nil)
        super(msg)
        @code = code || "UNKNOWN_ERROR"
        @title = title || "Something bad happend"
      end
    end

    class BadRequestError < ServerError
      def http_status
        400
      end

      def initialize(msg = nil)
        msg ||= "The request cannot be understood"
        super(msg, code: "INVALID_REQUEST", title: "Invalid request")
      end
    end

    class UnauthorizedError < ServerError
      def http_status
        401
      end

      def initialize(msg = nil)
        msg ||= "User is not authorized"
        super(msg, code: "UNAUTHORIZED", title: "Unauthorized user")
      end
    end

    class ForbiddenError < ServerError
      def http_status
        403
      end

      def initialize(msg = nil)
        msg ||= "User is not allowed to perform this action"
        super(msg, code: "FORBIDDEN", title: "User not allowed")
      end
    end

    class NotFoundError < ServerError
      attr_reader :clazz, :id

      def http_status
        404
      end

      def initialize(msg = nil, clazz: nil, id: nil)
        @clazz = clazz
        @id = id
        msg ||= "#{clazz ? "#{clazz.to_s} r" : "R"}esource with id #{id} does not exist"
        super(msg, code: "RESOURCE_NOT_FOUND", title: "Resource not found")
      end
    end

    class UnsupportedMediaTypeError < ServerError
      def http_status
        415
      end

      def initialize(msg = nil, request: nil)
        content_type = request&.env["CONTENT_TYPE"]
        msg = "Unsupported Media Type#{content_type ? ": #{content_type}" : ""}"
        super(msg, code: "UNSUPPORTED_MEDIA_TYPE", title: "Unsupported media type")
      end
    end
  end
end
