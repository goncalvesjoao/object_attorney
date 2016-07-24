lib = File.expand_path('../lib', __FILE__)

$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

require 'object_attorney/version'

Gem::Specification.new do |gem|
  gem.name = 'object_attorney'
  gem.version = ObjectAttorney::VERSION
  gem.license = 'MIT'
  gem.authors = ['João Gonçalves']
  gem.email = ['goncalves.joao@gmail.com']
  gem.summary = 'Ruby Form Object pattern implementation'
  gem.description = "This gem allows you to extract the code responsible for 'validations', 'nested objects' and 'strong parameters' from your model onto a specific class for a specific use case."
  gem.homepage = 'https://github.com/streetbees/object_attorney'

  gem.files = `git ls-files`.split($/)
  gem.executables = gem.files.grep(%r{^bin/}).map { |f| File.basename(f) }
  gem.test_files = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ['lib']

  gem.add_development_dependency 'pry', '0.10.3'
  gem.add_development_dependency 'rake', '11.2.2'
  gem.add_development_dependency 'rspec', '3.4.0'
  gem.add_development_dependency 'rubocop', '0.37.2'
  gem.add_development_dependency 'simplecov', '0.11.2'
  gem.add_development_dependency 'activemodel', '4.2.6'
  gem.add_development_dependency 'codeclimate-test-reporter', '0.4.8'

  # gem.add_dependency 'i18n', '~> 0.7'
end
