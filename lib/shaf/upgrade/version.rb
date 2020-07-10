module Shaf
  module Upgrade
    class Version
      include Comparable

      attr_reader :major, :minor, :patch

      alias eql? ==

      class UpgradeVersionError < StandardError
        def initialize(message = '')
          super("Bad upgrade version: #{message}")
        end
      end

      def initialize(version)
        case version
        when Version
          @major, @minor, @patch = version.to_a
        when /\d+\.\d+(\.\d+)?/
          @major, @minor, @patch = split_version(version)
        else
          raise UpgradeVersionError, version
        end
      end

      def <=>(other)
        return unless other
        other = self.class.new(other)
        compare_version(other.major, other.minor, other.patch)
      end

      def to_s
        to_a.join('.')
      end

      def to_a
        [major, minor, patch]
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
