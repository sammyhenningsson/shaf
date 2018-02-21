# -*- encoding: utf-8 -*-
Gem::Specification.new do |gem|
  gem.name        = 'shaf'
  gem.version     = '0.1.0'
  gem.date        = '2018-01-25'
  gem.summary     = "Sinatra Hypermedia Api Framework"
  gem.description = "A framework for building hypermedia driven APIs with sinatra and sequel."
  gem.authors     = ["Sammy Henningsson"]
  gem.email       = 'sammy.henningsson@gmail.com'
  gem.homepage    = "https://github.com/sammyhenningsson/shaf"
  gem.license     = "MIT"

  #gem.cert_chain  = ['certs/sammyhenningsson.pem']
  #gem.signing_key = File.expand_path("~/.ssh/gem-private_key.pem") if $0 =~ /gem\z/

  gem.executables   = ['shaf']
  gem.files         = Dir['lib/**/*rb'] + Dir['templates/**/*']
  gem.require_paths = ["lib"]

  gem.add_development_dependency "rake", '~> 12.0', '>= 10.0'
  gem.add_development_dependency "minitest", '~> 5.10', '>= 5.0'
  gem.add_development_dependency "hal_presenter", '~> 0.4.3', '>= 0.4.0'
  gem.add_development_dependency "sinatra", '~> 2.0.1', '>= 2.0.0'
  gem.add_development_dependency "sequel"
  gem.add_development_dependency "sinatra-sequel"
  gem.add_development_dependency "thin"
  gem.add_development_dependency "bcrypt"
  gem.add_development_dependency "redcarpet"
  gem.add_development_dependency "minitest-hooks"
  gem.add_development_dependency "rack-test"
end
