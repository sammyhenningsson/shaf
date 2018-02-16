require 'fileutils'
require 'yaml'
require 'shaf/version'

module Shaf
  module Command
    class New < Base

      identifier %r(\An(ew)?\Z)
      usage 'new PROJECT_NAME'

      def call
        @project_name = args.first
        if @project_name.nil? || @project_name.empty?
          raise ArgumentError,
            "Please provide a project name when using command 'new'!"
        end

        create_dir @project_name
        Dir.chdir(@project_name) do
          copy_templates
          create_shaf_version_file
        end
      end

      def create_dir(name)
        return if Dir.exist? name
        FileUtils.mkdir_p(name)
      rescue SystemCallError
        exit_with_error("Failed to create directory #{name}", 2)
      end

      def copy_templates
        template_files.each do |template|
          copy_template(template)
        end
      end

      def create_shaf_version_file
        File.write '.shaf',
          YAML.dump({'version' => Shaf::VERSION})
      end

      def copy_template(template)
        target = target_for(template)
        create_dir File.dirname(target)
        FileUtils.cp(template, target)
      end

      def template_dir
        File.expand_path('../../../../templates', __FILE__)
      end

      def template_files
        Dir["#{template_dir}/**/{*,.*}"].reject do |file|
          File.directory?(file)
        end
      end

      def target_for(template)
        template.sub("#{template_dir}/", "")
      end
    end
  end
end
