$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), "..", "lib"))

ENV["RAILS_ENV"] ||= 'test'

require 'bundler'
Bundler.setup
require 'rspec'
require 'pry'
require 'database_cleaner'

require "object_attorney"
require_relative 'support/post'
require_relative 'support/post_form'
require_relative 'support/database_setup'
require_relative 'support/active_model/validations'

RSpec.configure do |config|

  I18n.enforce_available_locales = false

  config.before(:suite) do
    DatabaseCleaner.strategy = :transaction
    DatabaseCleaner.clean_with(:truncation)
  end

  config.before(:each) do
    DatabaseCleaner.start
  end

  config.after(:each) do
    DatabaseCleaner.clean
  end

end