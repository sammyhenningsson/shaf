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
  gem.files         = Dir['lib/**/*.rb'] + Dir['templates/**/*.rb']
  gem.require_paths = ["lib"]

  gem.add_development_dependency "rake", '~> 12.0', '>= 10.0'
  gem.add_development_dependency "minitest", '~> 5.10', '>= 5.0'
end
