# frozen_string_literal: true

require 'erb'
require 'forwardable'
require 'yaml'
require 'csv'
require 'zlib'
require 'shaf/version'

module Shaf
  module Utils
    extend Forwardable

    class ProjectRootNotFound < StandardError; end

    SHAF_VERSION_FILE = '.shaf'.freeze

    class << self
      def model_name(name)
        name.capitalize.gsub(/[_-](\w)/) { $1.upcase }
      end

      def gem_root
        File.expand_path('../..', __dir__)
      end

      # FIXME!!!
      def pluralize(noun)
        return pluralize(noun.to_s).to_sym if noun.is_a? Symbol
        noun + 's'
      end

      # FIXME!!!
      def singularize(noun)
        return singularize(noun.to_s).to_sym if noun.is_a? Symbol
        return noun unless noun.end_with? 's'
        noun[0..-2]
      end

      def symbol_string(str)
        str.to_sym.inspect
      end

      def environment
        require 'sinatra/base'
        Sinatra::Application.settings.environment
      end

      def rackify_header(str)
        return if str.nil?
        str.upcase.tr('-', '_').tap do |key|
          key.prepend('HTTP_') unless key.start_with? 'HTTP_'
        end
      end

      def deep_symbolize_keys(value)
        deep_transform_keys(value) { |key| key.to_sym }
      end

      def deep_transform_keys(hash, &block)
        case hash
        when Hash
          hash.each_with_object({}) do |(k, v), h|
            key = block.call(k)
            h[key] = deep_transform_keys(v, &block)
          end
        when Array
          hash.map { |v| deep_transform_keys(v, &block) }
        else
          hash
        end
      end

      def deep_transform_values(hash, &block)
        case hash
        when Hash
          hash.each_with_object({}) do |(k, v), h|
            h[k] = deep_transform_values(v, &block)
          end
        when Array
          hash.map { |v| deep_transform_values(v, &block) }
        else
          block.call(hash)
        end
      end

      def read_config(file, erb: false, erb_binding: nil)
        return {} unless File.exist? file

        yaml = File.read(file)
        yaml = erb(yaml, binding: erb_binding) if erb || erb_binding
        if RUBY_VERSION < '2.6.0'
          deep_symbolize_keys(YAML.safe_load(yaml, [], [], true))
        else
          YAML.safe_load(yaml, aliases: true, symbolize_names: true)
        end
      end

      def iana_link_relations_csv
        zip_file = File.join(gem_root, 'iana_link_relations.csv.gz')
        Zlib::GzipReader.open(zip_file) { |content| CSV.new(content.read) }
      end

      private

      def erb(content, binding: nil)
        bindings = binding ? [binding] : []
        return ERB.new(content, 0, '%-<>').result(*bindings) if RUBY_VERSION < '2.6.0'
        ERB.new(content, trim_mode: '-<>').result(*bindings)
      end
    end

    def_delegators Utils, :pluralize, :singularize, :symbol_string, :gem_root, :rackify_header

    def project_root
      return @project_root if defined? @project_root
      dir = Dir.pwd
      while dir != '/' do
        return @project_root = dir if is_project_root?(dir)
        dir = File.expand_path("..", dir)
      end
    end

    def project_root!
      project_root or raise ProjectRootNotFound
    end

    def is_project_root?(dir)
      File.exist? File.expand_path(".shaf", dir)
    end

    def in_project_root?
      is_project_root?(Dir.pwd)
    end

    def in_project_root
      return unless block_given?
      Dir.chdir(project_root!) do
        $:.unshift Dir.pwd
        yield
      end
    end

    def bootstrap(env: 'development')
      in_project_root do
        ENV['RACK_ENV'] = env
        require 'config/bootstrap'
        yield if block_given?
      end
    end

    def read_shaf_file
      return {} unless File.exist? SHAF_VERSION_FILE
      str = File.read(SHAF_VERSION_FILE)
      YAML.load(str) || {}
    end

    def read_shaf_file!
      in_project_root do
        read_shaf_file
      end
    end

    def write_shaf_file(data = {})
      write_shaf_file! read_shaf_file.merge(data)
    end

    def write_shaf_file!(data = {})
      File.write SHAF_VERSION_FILE,
        YAML.dump(data)
    end

    def read_shaf_version
      read_shaf_file['version']
    end

    def read_shaf_upgrade_failure_version
      read_shaf_file['failed_upgrade']
    end

    def write_shaf_version(version = nil)
      version ||= Shaf::VERSION
      data = read_shaf_file.merge('version' => version.to_s)
      data.delete('failed_upgrade')
      write_shaf_file! data
    end

    def write_shaf_upgrade_failure(version)
      write_shaf_file 'failed_upgrade' => version.to_s
    end
  end
end
