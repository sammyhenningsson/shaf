module Shaf
  module RegistrableFactory

    class NotFoundError < StandardError; end

    def all
      reg.dup
    end

    def size
      reg.size
    end

    def register(clazz)
      reg << clazz
    end

    def unregister(*str)
      return if str.empty? || !str.all?
      reg.delete_if { |clazz| matching_class? str, clazz }
    end

    def lookup(*str)
      return if str.empty? || !str.all?
      reg.detect { |clazz| matching_class? str, clazz }
    end

    def usage
      reg.compact.map do |entry|
        usage = entry.instance_eval { @usage }
        usage.respond_to?(:call) ? usage.call : usage
      end
    end

    def create(*args)
      clazz = lookup(*args)
      return clazz.new(*args) if clazz
      raise NotFoundError.new(%Q(Command '#{args}' is not supported))
    end

    private

    def reg
      @reg ||= []
    end

    def matching_class?(strings, clazz)
      identifiers = clazz.instance_eval { @identifiers }
      return false if strings.size < identifiers.size
      identifiers.zip(strings).all? { |pattern, str| matching_identifier? str, pattern }
    end

    def matching_identifier?(str, pattern)
      return false if pattern.nil? || str.nil? || str.empty?
      pattern = pattern.to_s if pattern.is_a? Symbol
      return str == pattern if pattern.is_a? String
      str.match(pattern) || false
    end
  end
end
