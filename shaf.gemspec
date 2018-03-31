# -*- encoding: utf-8 -*-
require './lib/shaf/version'

Gem::Specification.new do |gem|
  gem.name        = 'shaf'
  gem.version     = Shaf::VERSION
  gem.summary     = "Sinatra Hypermedia Api Framework"
  gem.description = "A framework for building hypermedia driven APIs with sinatra and sequel."
  gem.authors     = ["Sammy Henningsson"]
  gem.email       = 'sammy.henningsson@gmail.com'
  gem.homepage    = "https://github.com/sammyhenningsson/shaf"
  gem.license     = "MIT"
  gem.metadata    = {
    "changelog_uri" => "https://github.com/sammyhenningsson/shaf/blob/master/CHANGELOG.md"
  }

  gem.cert_chain  = ['certs/sammyhenningsson.pem']
  gem.signing_key = File.expand_path("~/.ssh/gem-private_key.pem") if $0 =~ /gem\z/

  gem.executables   = ['shaf']
  gem.files         = Dir['lib/**/*rb'] + Dir['templates/**/*']
  gem.require_paths = ["lib"]

  gem.required_ruby_version = '>= 2.3'
  gem.add_development_dependency "rake", '~> 12.0', '>= 10.0'
  gem.add_development_dependency "minitest", '~> 5.10', '>= 5.0'
  gem.add_development_dependency "hal_presenter", '~> 0.4.3', '>= 0.4.0'
  gem.add_development_dependency "sinatra", '~> 2.0.1', '>= 2.0.0'
  gem.add_development_dependency "sequel", '~> 5.6'
  gem.add_development_dependency "sinatra-sequel", '~> 0.9.0'
  gem.add_development_dependency "thin", '~> 1.7', '>= 1.7.2'
  gem.add_development_dependency "bcrypt", '~> 3.1', '>= 3.1.11'
  gem.add_development_dependency "redcarpet", '~> 3.4'
  gem.add_development_dependency "minitest-hooks", '~> 1.4', '>= 1.4.2'
  gem.add_development_dependency "rack-test", '~> 0.8.3'
end
