require 'fileutils'
require 'yaml'
require 'erb'

module Shaf
  module Command
    class New < Base

      identifier %r(\An(ew)?\Z)
      usage 'new PROJECT_NAME'

      def call
        self.project_name = args.first
        if project_name.nil? || project_name.empty?
          raise ArgumentError,
            "Please provide a project name when using command 'new'!"
        end

        create_dir project_name
        Dir.chdir(project_name) do
          copy_templates
          create_gemfile
          create_settings_file
          write_shaf_version
          create_ruby_version_file
        end
      end

      private

      attr_accessor :project_name

      def create_dir(name)
        return if Dir.exist? name
        FileUtils.mkdir_p(name)
      rescue SystemCallError
        exit_with_error("Failed to create directory #{name}", 2)
      end

      def create_gemfile
        template_file = File.expand_path('../templates/Gemfile.erb', __FILE__)
        content = File.read(template_file)
        File.write "Gemfile", erb(content)
      end

      def create_settings_file
        settings_file = 'config/settings.yml'
        template_file = File.expand_path("../templates/#{settings_file}.erb", __FILE__)
        content = File.read(template_file)
        locals = {
          project_name: project_name.capitalize,
          default_port: "<%= ENV.fetch('PORT', 3000) %>"
        }
        File.write settings_file,
                   erb(content, locals)
      end

      def erb(content, locals = {})
        return ERB.new(content, 0, '%-<>').result_with_hash(locals) if RUBY_VERSION < "2.6.0"
        ERB.new(content, trim_mode: '-<>').result_with_hash(locals)
      end

      def copy_templates
        template_files.each do |template|
          copy_template(template)
        end
      end

      def create_ruby_version_file
        File.write '.ruby-version', RUBY_VERSION
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
