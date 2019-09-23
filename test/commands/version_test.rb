require 'test_helper'

module Shaf
  describe Command::Version do
    let(:cmd) { Command::Version.new }

    it 'prints shaf version' do
      output = Mutable.capture_output { cmd.call }
      _(output).must_match(/Installed Shaf version: #{VERSION}/)
      _(output).wont_match(/Project .+ created with Shaf version:/)
    end

    it 'prints shaf version and project version' do
      cmd.stub :project_root, '/my_project' do
        cmd.stub :read_shaf_version, '1.2.0' do
          output = Mutable.capture_output { cmd.call }
          _(output).must_match(/Installed Shaf version: #{VERSION}/)
          _(output).must_match(/Project 'my_project' created with Shaf version:/)
        end
      end
    end
  end
end
