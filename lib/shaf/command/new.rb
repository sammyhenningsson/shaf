require 'fileutils'
require 'byebug'

module Shaf
  module Command
    class New < BaseCommand
      def self.identified_by
        'new'
      end

      def self.usage
        'new PROJECT_NAME'
      end

      def call
        @project_name = args.shift
        if @project_name.nil? || @project_name.empty?
          raise ArgumentError, "Please provide a project name when using command 'new'!"
        end

        create_dir @project_name
        Dir.chdir(@project_name) { copy_templates }
      end

      def create_dir(name)
        return if Dir.exist? name
        FileUtils.mkdir_p(name)
      rescue SystemCallError
        exit_with_error("Failed to create directory #{name}", 2)
      end

      def copy_templates
        template_files.each { |template| copy_template(template) }
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
        Dir["#{template_dir}/**/*"].reject do |file|
          File.directory?(file)
        end
      end

      def target_for(template)
        template.sub("#{template_dir}/", "")
      end
    end
  end
end
