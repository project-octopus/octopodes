# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'octopodes/version'

Gem::Specification.new do |spec|
  spec.name          = 'octopodes'
  spec.version       = Octopodes::VERSION
  spec.authors       = ['Christopher Adams']
  spec.email         = ['christopher@fabricatorz.com']
  spec.summary       = %q{Reviewing the Use of Creative Works, One URL at a Time}
  spec.description   = %q{A prototype hypermedia API for recording the use of creative works and media objects on the World Wide Web.}
  spec.homepage      = 'https://github.com/DiUS/pact_broker'
  spec.license       = 'CC0 1.0 Universal'

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler', '~> 1.7'
  spec.add_development_dependency 'rake', '~> 10.0'

  spec.add_runtime_dependency 'webmachine', '~> 1.3.0'
  spec.add_runtime_dependency 'rack', '~> 1.6.0'

  spec.add_runtime_dependency 'collection-json'

  spec.add_runtime_dependency 'configatron', '~> 4.5.0'
  spec.add_runtime_dependency 'bcrypt', '~> 3.1.10'

  spec.add_runtime_dependency 'hashie', '~> 3.3.0'
  spec.add_runtime_dependency 'activemodel', '~> 4.2.0'

  spec.add_runtime_dependency 'compass', '~> 1.0.0'
  spec.add_runtime_dependency 'bootstrap-sass', '3.3.3'

  spec.add_development_dependency 'rspec', '~> 3.1.0'
  spec.add_development_dependency 'rspec_api_documentation', '~> 4.3.0'
  spec.add_development_dependency 'rack-test', '~> 0.6.3'
  spec.add_development_dependency 'json_spec', '~> 1.1.4'
end
