module Shaf
  module Upgrade
    class Version
      include Comparable

      attr_reader :major, :minor, :patch

      alias eql? ==

      class UpgradeVersionError < StandardError
        def initialize(message = "")
          super("Bad upgrade version: #{message}")
        end
      end

      def initialize(version)
        case version
        when Version
          @major, @minor, @patch = [:major, :minor, :patch].map { |m| version.send m }
        when /\d+\.\d+(\.\d+)?/
          @major, @minor, @patch = split_version(version)
        else
          raise UpgradeVersionError.new(version)
        end
      end

      def <=>(other)
        case other
        when String
          compare_version(*split_version(other))
        when Version
          compare_version(other.major, other.minor, other.patch)
        end
      end

      def to_s
        [major, minor, patch].join('.')
      end

      private

      def split_version(str)
        str.split('.').map(&:to_i).tap do |list|
          list << 0 while list.size < 3
        end
      end

      def compare_version(other_major, other_minor, other_patch)
        [
          major <=> other_major,
          minor <=> other_minor,
          patch <=> other_patch
        ].find { |x| !x.zero? } || 0
      end
    end
  end
end
