module Shaf
  module Command
    class Version < Base

      identifier %r(\Av(ersion)?\Z)
      usage 'version'

      def call
        print_shaf_version
        print_project_version
      end

      def print_shaf_version
        puts "Installed Shaf version: #{Shaf::VERSION}"
      end

      def print_project_version
        path = project_root
        return if path.nil?
        project = path.split('/').last
        puts "Project '#{project}' created with Shaf version: #{read_shaf_version}"
      end
    end
  end
end
