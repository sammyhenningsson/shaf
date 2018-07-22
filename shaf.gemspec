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
  gem.files         = Dir['lib/**/*rb'] + Dir['templates/**/*'] + Dir['upgrades/*.tar.gz']
  gem.require_paths = ["lib"]

  gem.required_ruby_version = '>= 2.3'
  gem.add_development_dependency "rake", '~> 12.0', '>= 10.0'
end
