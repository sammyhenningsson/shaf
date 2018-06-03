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
        if self.class === version
          @major, @minor, @patch = [:major, :minor, :patch].map { |m| version.send m }
        else
          raise UpgradeVersionError.new(version) unless version =~ /\d+\.\d+\.\d+/
          @major, @minor, @patch = split_version(version)
        end
      end

      def <=>(other)
        if other.is_a? String
          compare_version(*split_version(other))
        else
          compare_version(other.major, other.minor, other.patch)
        end
      end

      def to_s
        [major, minor, patch].join('.')
      end

      private

      def split_version(str)
        str.split('.').map(&:to_i)
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
