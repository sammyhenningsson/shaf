module Shaf
  module ApiDoc
    class Comment
      def initialize
        @indent = 0
        @comment = ""
      end

      def to_s
        @comment
      end

      def empty?
        @comment.empty?
      end

      def <<(line)
        @indent = line[/\A\s*/].size if empty?
        @comment << "\n#{extract(line)}"
      end

      def extract(line)
        line.sub(%r(\A\s{#{@indent}}), "")
      end
    end
  end
end
