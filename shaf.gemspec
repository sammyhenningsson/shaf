# -*- encoding: utf-8 -*-
Gem::Specification.new do |gem|
  gem.name        = 'shaf'
  gem.version     = '0.0.1'
  gem.date        = '2018-01-01'
  gem.summary     = "Sinatra Hypermedia Api Framework"
  gem.description = "A framework for building hypermedia driven APIs with sinatra."
  gem.authors     = ["Sammy Henningsson"]
  gem.email       = 'sammy.henningsson@gmail.com'
  gem.homepage    = "https://github.com/sammyhenningsson/hal_decorator"
  gem.license     = "MIT"

  #gem.cert_chain  = ['certs/sammyhenningsson.pem']
  #gem.signing_key = File.expand_path("~/.ssh/gem-private_key.pem") if $0 =~ /gem\z/

  puts "executables: #{gem.executables}"
  gem.executables   = ['shaf']
  gem.files         = Dir['lib/**/*.rb'] + Dir['templates/**/*.rb']
  puts "gem files: #{gem.files}"
  gem.require_paths = ["lib"]

  gem.add_development_dependency "rake", '~> 12.0', '>= 10.0'
  gem.add_development_dependency "minitest", '~> 5.10', '>= 5.0'
  gem.add_development_dependency "byebug", '~> 9.0', '>= 9.0'
end
