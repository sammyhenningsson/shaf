#!/usr/bin/env ruby

require 'shaf/upgrade'

# Example of manifest:
# ---
# target_version: 0.4.0
# patches:
#   cd5b0bf61070a9fd57e60c45e9aaf64a: config/database.rb
#   59783ecfa5f41b84c6fad734e7aa6a1d: Rakefile
# add:
#   8ece24b8c440675bd3d188155909431c: api/policies/base_policy.rb
# drop:
# - api/policies/base_policy.rb
# substitutes:
#   d3b07384d113edec49eaa6238ad5ff00: api/models/.*.rb


module Shaf
  class CreateUpgradePackage
    attr_reader :manifest, :tmp_dir

    class << self
      def call
        target_version, _ = ask_for('Target version')
        manifest = Upgrade::Manifest.new(target_version: target_version)
        create_upgrade_package = new(manifest)

        show_help

        create_upgrade_package.call
      end

      def ask_for(*requested, suffix: ': ')
        requested.each_with_object([]) do |str, values|
          print "\n#{str}#{suffix}"
          values << gets.chomp
        end
      end

      def show_help
        puts <<~MSG
        a/add:      Add a new file.
        d/delete:   Add pattern for files to be deleted.
        p/patch:    Add pattern for files to be modified by patch.
        r/regexp:   Add pattern for files to be modified by processing them line by line with a regexp.
        c/continue: Proceed with building the upgrade package.
        q/quit:     Quit the process with out creating any thing.

        MSG
      end
    end

    def initialize(manifest)
      @manifest = manifest
      @tmp_dir = Dir.mktmpdir
      puts "Temp dir: #{tmp_dir}"
    end

    def call
      build
    end

    def ask_for(*args)
      self.class.ask_for(*args)
    end

    def build
      while command = ask_for(command: '> ', suffix: '').first
        case command.downcase
        when 'a', 'add'
          ask_for(filename: 'Filename')
        when 'd', 'delete'
          ask_for(filename: 'Filename')
        when 'p', 'patch'
          ask_for(filename: 'Filename')
        when 'r', 'regexp'
          ask_for(filename: 'Filename')
        when 'c', 'continue'
          ask_for(filename: 'Filename')
        when 'q', 'quit'
          exit(0)
        else
          puts "Unknown command: #{command}"
        end
      end
    end
  end
end

Shaf::CreateUpgradePackage.call if File.expand_path($0) == File.expand_path(__FILE__)
