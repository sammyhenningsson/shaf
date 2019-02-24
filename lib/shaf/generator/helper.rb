require 'ostruct'

module Shaf
  module Generator
    class Helper < OpenStruct
      # public method mapped to Kernel's private #binding
      def binding
        super
      end

      def print(lines, indent_level = 2)
        strip_blank(lines).inject do |result, line|
          result + "\n#{i(indent_level) unless line.empty?}#{line}"
        end.chomp
      end

      def print_nested(sections, indent_level = 2)
        sections.map(&method(:print)).join("\n\n#{i(indent_level)}")
      end

      def strip_blank(lines)
        lines.map do |line|
          line.strip.empty? ? '' : line
        end
      end

      def indentation(level)
        ' ' * level
      end
      alias i indentation
    end
  end
end
