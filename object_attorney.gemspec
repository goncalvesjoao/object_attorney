lib = File.expand_path('../lib', __FILE__)

$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

require 'object_attorney/version'

Gem::Specification.new do |gem|
  gem.name = 'object_attorney'
  gem.version = ObjectAttorney::VERSION
  gem.license = 'MIT'
  gem.authors = ['João Gonçalves']
  gem.email = ['goncalves.joao@gmail.com']
  gem.summary = 'Allows you to keep your ActiveModel validations out' \
                ' of your objects'
  gem.description = 'This gem allows you to create use cases with ActiveModel' \
                    ' validations and keep your model clean'
  gem.homepage = 'https://github.com/streetbees/object_attorney'

  gem.files = Dir['README.md', 'lib/**/*']
  gem.executables = gem.files.grep(%r{^bin/}).map { |f| File.basename(f) }
  gem.test_files = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ['lib']

  gem.add_development_dependency 'pry', '0.11.3'
  gem.add_development_dependency 'rake', '12.3.0'
  gem.add_development_dependency 'rspec', '3.7.0'
  gem.add_development_dependency 'rubocop', '0.52.1'
  gem.add_development_dependency 'activemodel', '~> 4.1', '>= 4.1.11'
  gem.add_development_dependency 'codeclimate-test-reporter', '1.0.8'

  gem.add_dependency 'activemodel', '~> 4.1', '>= 4.1.11'
end
