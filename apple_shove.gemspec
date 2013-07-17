# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'apple_shove/version'

Gem::Specification.new do |spec|
  spec.name          = "apple_shove"
  spec.version       = AppleShove::VERSION
  spec.authors       = ["Taylor Boyko"]
  spec.email         = ["tboyko@unwiredrevolution.com"]
  spec.description   = %q{Apple Push Notification Service (APNS) provider. More powerful than a push...}
  spec.summary       = %q{}
  spec.homepage      = "https://github.com/tboyko/apple_shove"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency 'rspec'
  spec.add_development_dependency 'rake'
  spec.add_dependency 'redis',            '~> 3.0'
  spec.add_dependency 'daemons',          '~> 1.1'
  spec.add_dependency 'celluloid',        '~> 0.13'
end