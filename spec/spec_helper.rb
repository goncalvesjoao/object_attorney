$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), "..", "lib"))

ENV["RAILS_ENV"] ||= 'test'

require 'bundler'
Bundler.setup
require 'rspec'
require 'pry'
#require 'database_cleaner'

require "object_attorney"
require_relative 'support/database_setup'
require_relative 'support/active_model/validations'
require_relative 'support/models/post'
require_relative 'support/models/post_form'

RSpec.configure do |config|

  I18n.enforce_available_locales = false

  # see: http://iain.nl/testing-activerecord-in-isolation
  config.around do |example|
    ActiveRecord::Base.transaction do
      example.run
      raise ActiveRecord::Rollback
    end
  end

  # see: https://github.com/bmabey/database_cleaner#rspec-example
  # config.before(:suite) do
  #   DatabaseCleaner.strategy = :transaction
  #   DatabaseCleaner.clean_with(:truncation)
  # end

  # config.before(:each) do
  #   DatabaseCleaner.start
  # end

  # config.after(:each) do
  #   DatabaseCleaner.clean
  # end

end