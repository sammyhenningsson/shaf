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
        Dir.chdir(project_name) do
          Bundler.with_clean_env { `bundle install` }
        end
      end
    end

    after do
      FileUtils.remove_dir(tmp_dir)
    end

    def with_server(port: 3030)
      pid = nil
      Dir.chdir(project_path) do
        pid = Test.spawn("bundle exec shaf server -p #{port}", out: File::NULL, err: [:child, :out])
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

    def get_root(port: 3030)
      get("http://localhost:#{port}/")
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
        assert Test.system("bundle exec shaf generate scaffold post message:string:Meddelande author:integer:Författare")
        assert Test.system("bundle exec rake db:migrate")

        with_server do
          get_root
          get_link('posts')
        end
      end
    end

    it "passes specs" do
      Dir.chdir(project_path) do
        assert Test.system("bundle exec shaf generate scaffold --specs post message:string:Meddelande author:integer:Författare")
        assert Test.system("bundle exec rake db:migrate")
        assert Test.system("bundle exec rake test")
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

        exit_status =  Test.system("bundle exec shaf my_command") do |out, err|
          assert_equal "hej", out
          assert err.empty?
        end
        assert exit_status
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

              def call(*)
                write_output('#{filename}', '#{content}')
              end
            end
          EOS
        end
        assert Test.system("bundle exec shaf generate my_generator")
        assert File.exist?(filename)
        assert_equal File.read(filename), content
      end
    end

    it "seed the db" do
      Dir.chdir(project_path) do
        assert Test.system("bundle exec shaf generate scaffold user name:string")
        # Currenly the model generator creates a borken serializer, due to undefined uri helpers.
        # (Unless the corresponding controller and uri_helpers have been defined).
        # Change scaffold to model, when that has been fixed!!
        # assert system("shaf generate model user name:string", out: File::NULL)

        Dir.mkdir "db/seeds"
        File.open("db/seeds.rb", "w") do |f|
          f.puts <<~RUBY
            User.create(name: "user1")
          RUBY
        end

        File.open("db/seeds/users.rb", "w") do |f|
          f.puts <<~RUBY
            User.create(name: "user2")
          RUBY
        end

        File.open("db/seeds/more_users.rb", "w") do |f|
          f.puts <<~RUBY
            User.create(name: "user3")
          RUBY
        end

        assert Test.system("bundle exec rake db:migrate")
        assert Test.system("bundle exec rake db:seed")

        exit_status = Test.system("bundle exec shaf console", stdin: "User.count") do |out, err|
          output_rows = out.split("\n").map(&:strip)
          i = output_rows.find_index "User.count"
          user_count = output_rows[i + 1].to_i
          assert_equal 3, user_count
        end
        assert exit_status
      end
    end
  end
end
