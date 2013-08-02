# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'object_attorney/version'

Gem::Specification.new do |spec|
  spec.name          = "object_attorney"
  spec.version       = ObjectAttorney::VERSION
  spec.authors       = ["João Gonçalves"]
  spec.email         = ["goncalves.joao@gmail.com"]
  spec.description   = %q{Form Object Patter Implementation}
  spec.summary       = %q{This gem allows you to extract the code responsible for Validations, Nested Objects and Forms, from your model, into a specific class for a specific use case.}
  spec.homepage      = "https://github.com/goncalvesjoao/object_attorney"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"

  spec.add_dependency(%q<rails>, [">= 3.0.0"])
  spec.add_dependency(%q<actionpack>, [">= 3.0.0"])
end
