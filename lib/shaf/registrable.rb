module Shaf
  module Registrable
    def all
      reg.dup
    end

    def size
      reg.size
    end

    def register(clazz)
      reg << clazz
    end

    def unregister(str)
      return if str.nil? || str.empty?
      reg.delete_if do |clazz|
        pattern = clazz.instance_eval { @id }
        matching_identifier? str, pattern
      end
    end

    def lookup(str)
      return if str.nil? || str.empty?
      reg.detect do |clazz|
        pattern = clazz.instance_eval { @id }
        matching_identifier? str, pattern
      end
    end

    def usage
      reg.map {|cmd| cmd.instance_eval { @usage } }.compact
    end

    private

    def reg
      @reg ||= []
    end

    def matching_identifier?(str, pattern)
      return false if pattern.nil? || pattern.empty?
      return str == pattern if pattern.is_a? String
      str&.match(pattern) || false
    end
  end
end
