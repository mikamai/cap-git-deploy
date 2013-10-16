# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'cap-git-deploy/version'

Gem::Specification.new do |spec|
  spec.name          = 'cap-git-deploy'
  spec.version       = Cap::Git::Deploy::VERSION
  spec.authors       = ['Nicola Racco', 'Elia Schito']
  spec.email         = ['nicola@mikamai.com']
  spec.description   = %q{Mikamai-style capistrano git deployment strategy}
  spec.summary       = %q{Mikamai-style capistrano git deployment strategy}
  spec.homepage      = 'http://www.mikamai.com'
  spec.license       = 'MIT'

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.add_runtime_dependency 'capistrano', '~> 2.0'
  spec.add_runtime_dependency 'grit'

  spec.add_development_dependency 'rake'
end
