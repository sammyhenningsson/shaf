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
      pid = nil
      Dir.chdir(project_path) do
        pid = spawn("shaf server", out: File::NULL, err: [:child, :out])
        sleep 1
        yield
      end
    ensure
      Process.kill("TERM", pid)
      Process.waitpid2(pid)
    end

    def get(uri)
      response = Net::HTTP.get(URI(uri))
      assert response, "Failed to get response from server"
      @response = JSON.parse(response)
    end

    def get_root
      get("http://localhost:3000/")
    end

    def get_link(rel)
      assert @response["_links"][rel],
        "Response does not contain link with rel '#{rel}', #{@response}"
      get(@response["_links"][rel]["href"])
    end

    it "copies templates" do
      Dir.chdir(project_path) do
        %w(Gemfile Rakefile config.ru .shaf config/bootstrap.rb config/settings.yml
        config/constants.rb config/database.rb config/directories.rb config/helpers.rb
        config/initializers.rb config/initializers/db_migrations.rb
        config/initializers/hal_presenter.rb config/initializers/logging.rb
        config/initializers/sequel.rb api/controllers/base_controller.rb
        api/controllers/root_controller.rb api/controllers/docs_controller.rb
        api/serializers/error_serializer.rb api/serializers/form_serializer.rb
        api/serializers/root_serializer.rb frontend/assets/css/main.css
        frontend/views/form.erb frontend/views/layout.erb
        frontend/views/payload.erb spec/spec_helper.rb
        spec/serializers/root_serializer_spec.rb spec/integration/root_spec.rb
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

    it "passes specs" do
      Dir.chdir(project_path) do
        assert system("shaf generate scaffold post message:string:Meddelande author:integer:Författare", out: File::NULL)
        assert system("rake db:migrate", out: File::NULL)
        assert system("rake test", out: File::NULL, err: File::NULL)
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
