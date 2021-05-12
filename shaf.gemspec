require './lib/shaf/version'

Gem::Specification.new do |gem|
  gem.name        = 'shaf'
  gem.version     = Shaf::VERSION
  gem.summary     = 'Sinatra Hypermedia Api Framework'
  gem.description = 'A framework for building hypermedia driven APIs with sinatra and sequel.'
  gem.authors     = ['Sammy Henningsson']
  gem.email       = 'sammy.henningsson@gmail.com'
  gem.license     = 'MIT'
  gem.metadata    = {
    'changelog_uri' => 'https://github.com/sammyhenningsson/shaf/blob/master/CHANGELOG.md',
    'homepage_uri'  => 'https://github.com/sammyhenningsson/shaf'
  }
  gem.cert_chain  = ['certs/sammyhenningsson.pem']

  unless ["0", "false", "off"].include? ENV["SIGN"]
    gem.signing_key = File.expand_path('~/.ssh/gem-private_key.pem')
  end

  gem.executables   = ['shaf']
  gem.files         = Dir['lib/**/*rb'] \
                    + Dir['templates/**/*'] \
                    + Dir['yard_templates/**/*'] \
                    + Dir['upgrades/*.tar.gz'] \
                    + ['iana_link_relations.csv.gz']
  gem.require_paths = ['lib']

  gem.required_ruby_version = '>= 2.5'
  gem.add_runtime_dependency 'file_transactions'
  gem.add_development_dependency 'minitest', '~> 5', '~> 5.14'
  gem.add_development_dependency 'rack-test', '~> 1.0'
  gem.add_development_dependency 'rake', '~> 12.0'
  gem.add_development_dependency 'sequel', '~> 5'
  gem.add_development_dependency 'sinatra', '~> 2.0'
  gem.add_development_dependency 'sqlite3', '~> 1.3'
  gem.add_development_dependency 'yard', '~> 0.9'
  gem.add_development_dependency 'redcarpet', '~> 3.5'
  gem.add_development_dependency 'faraday', '~> 0.17'
  gem.add_development_dependency 'git', '~> 1.5'
  gem.add_development_dependency 'bundler', '~> 2.1'
  gem.add_development_dependency 'hal_presenter', '~> 1.6'
  gem.add_development_dependency 'byebug'
end
