# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'cap-git-deploy/version'

Gem::Specification.new do |gem|
  gem.name          = 'cap-git-deploy'
  gem.version       = Cap::Git::Deploy::VERSION
  gem.authors       = ['Nicola Racco', 'Elia Schito']
  gem.email         = ['nicola@mikamai.com']
  gem.description   = %q{Mikamai-style deploy strategy}
  gem.summary       = %q{Mikamai-style deploy strategy}
  gem.homepage      = "http://www.mikamai.com"

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]

  gem.add_runtime_dependency 'capistrano'
  gem.add_runtime_dependency 'grit'

  gem.add_development_dependency 'rake'
end
