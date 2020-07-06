# frozen_string_literal: true

module Shaf
  module Yard
    class Parser
      def self.call(name: '')
        new(name).parse!
      end

      def initialize(name)
        @name = name.downcase
      end

      def parse!
        verify_exists! unless name.empty?
        ::YARD.parse pattern
      end

      private

      attr_reader :name

      def pattern
        return file_path if file_path

        base = ['*', suffix].join
        File.join(base_dir, '**', base)
      end

      def suffix
        '_serializer.rb'
      end

      def verify_exists!
        file_path or raise <<~ERR
          Could not find a matching serializer for #{name}.
          Looked in: #{base_dir}
          Using suffix: #{suffix}
        ERR
      end

      def file_path
        @file_path ||= lookup_path
      end

      def base_dir
        File.join(Shaf::Settings.app_dir || 'api', 'serializers')
      end

      def lookup_path
        return if name.empty?

        path = File.join(base_dir, name)
        return path if File.exist? path

        with_suffix = [path, suffix].join
        return with_suffix if File.exist? with_suffix

        with_extension = [path, '.rb'].join
        with_extension if File.exist? with_extension
      end
    end
  end
end
