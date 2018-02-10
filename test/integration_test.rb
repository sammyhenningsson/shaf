require 'test_helper'
require 'tmpdir'
require 'fileutils'
require 'net/http'
require 'uri'

module Shaf
  describe "Setting up a new project" do
    let(:tmp_dir) { Dir.mktmpdir }
    let(:project_name) { "blog" }
    let(:project_path) { File.join(tmp_dir, project_name) }

    before do
      Dir.chdir(tmp_dir) do
        Command::New.new(project_name).call
      end
    end

    after do
      FileUtils.remove_dir(tmp_dir)
    end

    def with_server
      Dir.chdir(project_path) do
        pid = spawn("rackup", out: File::NULL, err: [:child, :out])
        sleep 1
        yield
      ensure
        Process.kill("TERM", pid)
        Process.waitpid2(pid)
      end
    end

    def get(uri)
      response = Net::HTTP.get(URI(uri))
      assert response, "Failed to get response from server"
      @response = JSON.parse(response)
    end

    def get_root
      get("http://localhost:9292/")
    end

    def get_link(rel)
      assert @response["_links"][rel],
        "Response does not contain link with rel '#{rel}', #{@response}"
      get(@response["_links"][rel]["href"])
    end

    it "copies templates" do
      Dir.chdir(project_path) do
        %w(Gemfile Rakefile config.ru .shaf config/app.rb config/bootstrap.rb
        config/constants.rb config/database.rb config/directories.rb config/helpers.rb
        config/initializers.rb config/initializers/db_migrations.rb
        config/initializers/hal_presenter.rb config/initializers/logging.rb
        config/initializers/sequel.rb app/controllers/base_controller.rb
        app/controllers/root.rb app/serializers/errors.rb app/serializers/form.rb
        app/serializers/root.rb frontend/assets/css/main.css frontend/views/form.erb
        frontend/views/layout.erb frontend/views/payload.erb test/test_helper.rb
        ).each do |file|
          assert File.exist?(file),
            "The file '#{file}' does not exist in a newly created project"
        end
      end
    end

    it "starts the server" do
      with_server do
        get_root
        get_link('self')
      end
    end

    it "adds a link to a new resource" do
      Dir.chdir(project_path) do
        assert system("shaf generate scaffold post message:string:Meddelande author:integer:Författare", out: File::NULL)
        assert system("rake db:migrate", out: File::NULL)
        with_server do
          get_root
          get_link('posts')
        end
      end
    end

    it "can use custom commands" do
      Dir.chdir(project_path) do
        File.open("config/customize.rb", "w") do |f|
          f.puts <<~EOS
            require 'shaf'

            class CustomCommand < Shaf::Command::Base
              identifier :my_command
              usage      "my_command"

              def call
                puts "hej"
              end
            end
          EOS
        end
        r, w = IO.pipe
        assert system("shaf my_command", out: w, err: [:child, :out])
        w.close
        output = r.read.chomp
        r.close
        assert_equal "hej", output
      end
    end

    it "can use custom generators" do
      Dir.chdir(project_path) do

        filename = 'lib/generators/my_generator.rb'
        content = 'Some content'

        File.open("config/customize.rb", "w") do |f|
          f.puts <<~EOS
            require 'shaf'

            class CustomGenerator < Shaf::Generator::Base

              identifier :my_generator
              usage 'generate my_generator'

              def call
                write_output('#{filename}', '#{content}')
              end
            end
          EOS
        end
        assert system("shaf generate my_generator", out: File::NULL, err: [:child, :out])
        assert File.exist?(filename)
        assert_equal File.read(filename), content
      end
    end
  end
end
