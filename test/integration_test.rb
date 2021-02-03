# frozen_string_literal: true

require 'test_helper'
require 'tmpdir'
require 'fileutils'
require 'socket'
require 'logger'
require 'faraday'
require 'git'

module Shaf
  describe "Setting up a new project" do
    let(:tmp_dir) { Dir.mktmpdir }
    let(:project_name) { "blog" }

    before do
      setup_project
    end

    after do
      reset_project
    end

    def setup_project
      return if defined? @@project_path

      Dir.chdir(tmp_dir) do
        Command::New.new(project_name).call
        Dir.chdir(project_name) do
          Test.patch_gemfile_shaf_path
          Test.bundle_install
          setup_git_repo
        end
      end

      @@project_path =  File.join(tmp_dir, project_name)
    end

    def setup_git_repo
      git = Git.init
      git.config('user.name', 'Shaf IntegrationTest')
      git.config('user.email', 'shaf@integration.test')
      git.add
      git.commit('clean')
    end

    def reset_project
      assert defined? @@project_path
      git = Git.open(@@project_path)
      git.reset_hard
      git.clean(force: true, d: true)
    end

    def verbose?
      ENV["VERBOSE"].to_i == 1
    end

    def with_server(port: nil)
      port ||= get_server_port
      pid = nil
      Dir.chdir(@@project_path) do
        redirects = {out: File::NULL}
        redirects[:err] = [:child, :out] unless verbose?
        pid = Test.spawn("bundle exec shaf server -p #{port}", redirects: redirects)
        sleep 2
        yield port
      end
    rescue StandardError => e
      STDERR.puts "\n Failed to start server: #{e.message}"
      STDERR.puts e.backtrace if verbose?
    ensure
      return unless pid
      Process.kill("TERM", pid)
      Process.waitpid2(pid)
    end

    def get_server_port
      server = TCPServer.new('127.0.0.1', 0)
      port = server.addr[1]
      server.close
      port
    end

    def get(uri, expected_status: 200, **opts)
      headers = {'Accept' => 'application/hal+json'}.merge(opts.fetch(:headers, {}))
      response = Faraday.get(uri, {}, headers)
      body = response.body

      assert body, "Failed to get response from server"
      assert_equal expected_status, response.status, <<~MSG
        Server responded with status #{response.status} (expected: #{expected_status})
        Response: #{body}
      MSG
      @response = response
      @body = JSON.parse(body)
    end

    def post(uri, data, expected_status: 201, **opts)
      headers = {
        'Accept' => 'application/hal+json',
        'Content-Type' => 'application/json'
      }.merge(opts.fetch(:headers, {}))

      data = JSON.generate(data) if data.is_a? Hash
      response = Faraday.post(uri, data, headers)
      body = response.body

      assert response.body, "POST request failed"
      assert_equal expected_status, response.status, <<~MSG
        Server responded with status #{response.status} (expected: #{expected_status})
        Response: #{body}
      MSG

      @response = response
      @body = JSON.parse(body)
    end

    def get_root(port: 3030, **opts)
      get("http://localhost:#{port}/", **opts)
    end

    def get_link(rel, **opts)
      assert @body&.dig("_links", rel),
        "Response does not contain link with rel '#{rel}', #{@body}"
      get(@body["_links"][rel]["href"], **opts)
    end

    def create_resource(**opts)
      get_link('create-form')
      target = @body['href']
      form = @body['fields'].each_with_object({}) do |field, values|
        name = field['name'].to_sym
        values[name] =
          if opts.key? name
             opts[name]
          elsif field['type'] == 'string'
            'lorem ipsum'
          elsif field['type'] == 'integer'
            5
          end
      end

      post target, form
    end

    it "copies templates" do
      Dir.chdir(@@project_path) do
        %w(Gemfile Rakefile config.ru .shaf config/bootstrap.rb
          config/settings.yml config/paths.rb config/database.rb
          config/directories.rb config/helpers.rb config/initializers.rb
          config/initializers/db_migrations.rb
          config/initializers/authentication.rb
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
      with_server do |port|
        get_root(port: port)
        get_link('self')
      end
    end

    it "adds a link to a new resource" do
      Dir.chdir(@@project_path) do
        assert Test.system("bundle exec shaf generate scaffold post message:string:Meddelande author:integer:Författare")
        assert Test.system("bundle exec rake db:migrate")

        with_server do |port|
          get_root(port: port)
          get_link('posts')
        end
      end
    end

    it "passes specs" do
      Dir.chdir(@@project_path) do
        assert Test.system("bundle exec shaf generate scaffold post message:string:Meddelande author:integer:Författare")
        assert Test.system("bundle exec rake db:migrate")
        assert Test.system("bundle exec shaf test")
      end
    end

    it "can use custom commands" do
      Dir.chdir(@@project_path) do
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
      Dir.chdir(@@project_path) do

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
        assert_equal content, File.read(filename)
      end
    end

    it "authenticates" do
      Dir.chdir(@@project_path) do
        File.open("config/initializers/authentication.rb", "w") do |f|
          f.puts <<~EOF
            require 'shaf'
            require 'ostruct'

            Shaf::Authenticator::BasicAuth.restricted realm: 'MyApi' do |user, password|
              return unless user && user == password
              OpenStruct.new(name: user)
            end
          EOF
        end

        File.open("api/controllers/test_controller.rb", "w") do |f|
          f.puts <<~EOF
            require 'serializers/base_serializer'

            class UserSerializer < BaseSerializer
              attribute :name
            end

            class TestController < BaseController
              get '/foo' do
                www_authenticate realm: 'MyApi'
                respond_with nil, status: 200, serializer: RootSerializer
              end

              get '/bar' do
                authenticate!
                respond_with current_user, status: 200, serializer: UserSerializer
              end
            end
          EOF
        end
      end

      with_server do |port|
        base_uri = "http://localhost:#{port}"
        get("#{base_uri}/foo")
        assert_includes @response.headers.keys, 'www-authenticate'
        assert_equal 'Basic realm="MyApi"', @response.headers['www-authenticate']

        good_credentials = ['bob:bob'].pack("m*").chomp
        get(
          "#{base_uri}/bar",
          expected_status: 200,
          headers: {'Authorization': "Basic #{good_credentials}"}
        )
        assert_equal('bob', @body['name'])
        refute_includes @response.headers.keys, 'www-authenticate'

        bad_credentials = ['bob:123'].pack("m*").chomp
        get(
          "#{base_uri}/bar",
          expected_status: 401,
          headers: {'Authorization': "Basic #{bad_credentials}"}
        )
        assert_includes @response.headers.keys, 'www-authenticate'
        assert_equal 'Basic realm="MyApi"', @response.headers['www-authenticate']
      end
    end

    it 'seeds the db' do
      Dir.chdir(@@project_path) do
        assert Test.system('shaf generate scaffold user name:string')

        Dir.mkdir 'db/seeds'
        File.open('db/seeds.rb', 'w') do |f|
          f.puts <<~RUBY
            User.create(name: 'one')
          RUBY
        end

        File.open("db/seeds/users.rb", "w") do |f|
          f.puts <<~RUBY
            User.create(name: 'two')
          RUBY
        end

        File.open('db/seeds/more_users.rb', 'w') do |f|
          f.puts <<~RUBY
            User.create(name: 'three')
          RUBY
        end

        assert Test.system('bundle exec rake db:migrate')
        assert Test.system('bundle exec rake db:seed')

        exit_status = Test.system('bundle exec shaf console', stdin: "User.count\n") do |out, err|
          assert_empty String(err)
          assert_match %r{User\.count}, out
          output_rows = out.split("\n").map(&:strip)
          i = output_rows.find_index 'User.count'
          assert i
          user_count = output_rows[i + 1].to_i
          assert_equal 3, user_count.to_i
        end
        assert exit_status
      end
    end

    it 'adds links to the profile from the resource' do
      Dir.chdir(@@project_path) do
        assert Test.system(
          "bundle exec shaf generate scaffold " \
          "post message:string:Meddelande author:integer:Författare"
        )
        assert Test.system("bundle exec rake db:migrate")

        with_server do |port|
          get_root(port: port)
          get_link('posts')
          create_resource
          get_link('self')
          get_link('profile', headers: {'Accept' => 'application/alps+json'})
        end
      end
    end
  end
end
