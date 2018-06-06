module Shaf
  module Utils
    class ProjectRootNotFound < StandardError; end

    SHAF_VERSION_FILE = '.shaf'.freeze

    # FIXME!!!
    def self.pluralize(noun)
      noun + 's' # FIXME!!
    end

    def self.model_name(name)
      name.capitalize.gsub(/[_-](\w)/) { $1.upcase }
    end

    def self.gem_root
      File.expand_path('../../..', __FILE__)
    end

    # FIXME!!!
    def self.singularize(noun)
      return singularize(noun.to_s).to_sym if noun.is_a? Symbol
      return noun unless noun.end_with? 's'
      noun[0..-2]
    end

    def gem_root
      self.class.gem_root
    end

    def project_root
      dir = Dir.pwd
      20.times do
        if is_project_root?(dir)
          return dir
        elsif dir == '/'
          break
        end
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

    def bootstrap
      in_project_root do
        ENV['RACK_ENV'] ||= 'development'
        require 'config/bootstrap'
        yield if block_given?
      end
    end

    def pluralize(noun)
      Utils::pluralize(noun)
    end

    def read_shaf_file
      return {} unless File.exist? SHAF_VERSION_FILE
      str = File.read(SHAF_VERSION_FILE)
      YAML.load(str) || {}
    end

    def write_shaf_file(data = {})
      data = read_shaf_file.merge(data)
      File.write SHAF_VERSION_FILE,
        YAML.dump(data)
    end

    def read_shaf_version
      read_shaf_file['version']
    end

    def write_shaf_version(version = nil)
      write_shaf_file('version' => version || Shaf::VERSION)
    end
  end
end
