module Shaf
  module Utils
    class ProjectRootNotFound < StandardError; end

    def self.pluralize(noun)
      noun + 's' #FIXME
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
      raise ProjectRootNotFound
    end

    def is_project_root?(dir)
      File.exist? File.expand_path(".shaf", dir)
    end

    def in_project_root?
      is_project_root?(Dir.pwd)
    end

    def in_project_root
      return unless block_given?
      Dir.chdir(project_root) do
        $:.unshift Dir.pwd
        yield
      end
    end

    def bootstrap
      in_project_root do
        ENV['RACK_ENV'] ||= 'development'
        require 'config/bootstrap'
      end
    end

    def pluralize(noun)
      Utils::pluralize(noun)
    end
  end
end
