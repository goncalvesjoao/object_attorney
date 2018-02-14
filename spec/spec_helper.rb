require 'simplecov'

SimpleCov.start do
  root('lib/')
  coverage_dir('../tmp/coverage/')
end

$LOAD_PATH << File.expand_path('../', File.dirname(__FILE__))

require 'pry'
require 'object_attorney'

Dir['./spec/**/support/**/*.rb'].each do |file|
  require file
end

RSpec.configure do |config|
  config.run_all_when_everything_filtered = true

  config.order = 'random'
end
