# frozen_string_literal: true

require 'fileutils'
require 'erb'
require 'file_transactions'
require 'shaf/generator/helper'

module Shaf
  module Generator
    class Base
      attr_reader :args, :options

      class << self
        def inherited(child)
          Factory.register(child)
        end

        def identifier(*ids)
          @identifiers = ids.flatten
        end

        def usage(str = nil, &block)
          @usage = str || block
        end

        def identified_by
          @identifiers
        end

        def options(option_parser, options); end
      end

      def initialize(*args, **options)
        @args = args
        @options = options
      end

      def call; end

      def identifier
        self.class.identified_by
      end

      private

      def params
        args[1..-1].map { |param| param.split(':')}
      end

      def name_arg
        n = args.first || ''
        return n unless n.empty?
        raise Command::ArgumentError,
          "Please provide a name when using the #{identifier} generator!"
      end

      def name
        name_arg.split('/', 2).last
      end

      def model_class_name
        Utils.model_name(name)
      end

      def plural_name
        Utils.pluralize(name)
      end

      def namespace
        names = name_arg.split('/')
        return if names.size == 1

        warn "Only a single namespaces is allowed: #{name_arg}" if names.size > 2

        names.first
      end

      def module_name
        Utils.model_name(namespace) if namespace
      end

      def target(directory: target_dir, ns: namespace, name: target_name)
        File.join(*[directory, ns, name].compact)
      end

      def template_dir
        File.expand_path('templates', __dir__)
      end

      def read_template(file, directory = nil)
        directory ||= template_dir
        filename = File.join(directory, file)
        filename << '.erb' unless filename.end_with?('.erb')
        File.read(filename)
      end

      def render(template, locals = {})
        str = read_template(template)
        locals[:changes] ||= []
        b = Helper.new(locals).binding

        return ERB.new(str, 0, '%-<>').result(b) if RUBY_VERSION < '2.6.0'
        ERB.new(str, trim_mode: '-<>').result(b)
      rescue SystemCallError => e
        puts "Failed to render template #{template}: #{e.message}"
        raise
      end

      def wrap_in_module(content, module_name, search: nil)
        return content if module_name.nil? || module_name.empty?

        indentation = '  '
        search ||= '(class|module) \w'
        lines = []
        added = false

        content.split("\n").each do |line|
          unless added
            if m = line.match(/\A(\s*)#{search}/)
              lines << "#{m[1]}module #{module_name}"
              added = true
            end
          end

          line.prepend(indentation) if added
          lines << line
        end

        lines << 'end' if added
        lines.join("\n")
      end

      def write_output(file, content)
        FileTransactions::CreateFileCommand.execute(file) { content }
        puts "Added:      #{file}"
      end
    end
  end
end
