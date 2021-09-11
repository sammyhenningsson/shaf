module Shaf
  module RegistrableFactory
    class NotFoundError < StandardError; end
    class NoIdentifiersError < StandardError

      def initialize(clazz)
        super <<~ERR
          #{clazz} does not have an @identifiers ivar.
          Did you perhaps forget to call `#{clazz}.identifier`?
        ERR
      end
    end

    class Entry
      attr_reader :clazz

      def initialize(clazz)
        @clazz = clazz
      end

      def match?(strings)
        raise NoIdentifiersError, clazz unless identifiers
        return false if strings.size < identifiers.size
        identifiers.zip(strings).all? { |pattern, str| matching_identifier? str, pattern }
      end

      def identifier_count
        identifiers&.size || 0
      end

      def usage
        clazz.instance_variable_get(:@usage)
      end

      private

      def identifiers
        clazz.identified_by
      end

      def matching_identifier?(str, pattern)
        return false if pattern.nil? || str.nil? || str.empty?
        pattern = pattern.to_s if pattern.is_a? Symbol
        return str == pattern if pattern.is_a? String
        !!str.match(pattern)
      end
    end

    def all
      reg.map(&:clazz)
    end

    def each(&block)
      return all.each unless block_given?
      all.each(&block)
    end

    def size
      reg.size
    end

    def register(clazz)
      reg << Entry.new(clazz)
    end

    def unregister(*str)
      return if str.empty? || !str.all?
      reg.delete_if { |entry| entry.match? str }
    end

    def lookup(*str)
      lookup_entry(*str)&.clazz
    end

    def usage
      reg.compact.map do |entry|
        usage = entry.usage
        usage.respond_to?(:call) ? usage.call : usage
      end
    end

    def create(*params, **options)
      entry = lookup_entry(*params)
      raise NotFoundError.new(%Q(Command '#{ARGV}' is not supported)) unless entry

      args = init_args(entry, params)
      entry.clazz.new(*args, **options)
    end

    private

    def reg
      @reg ||= []
    end

    def lookup_entry(*str)
      return if str.empty? || !str.all?
      reg.select { |entry| entry.match? str }
        .sort_by { |entry| entry.identifier_count }
        .last
    end

    def init_args(entry, params)
      first_non_id = entry.identifier_count
      params[first_non_id..-1]
    end
  end
end
