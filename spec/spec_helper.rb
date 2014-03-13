$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), "..", "lib"))

ENV["RAILS_ENV"] ||= 'test'

require 'bundler'
Bundler.setup
require 'rspec'
require 'pry'
#require 'database_cleaner'

require 'object_attorney'
require 'support/database_setup'
require 'support/active_model/validations'
require 'support/models/address'
require 'support/models/comment'
require 'support/models/post'
require 'support/models/user'

require 'support/form_objects/post_form'
require 'support/form_objects/post_validations_form'
require 'support/form_objects/comment_form'
require 'support/form_objects/post_with_comment_form'
require 'support/form_objects/post_with_comment_validations_form'
require 'support/form_objects/post_with_comments_and_address_form'
require 'support/form_objects/post_with_only_new_comments_form'
require 'support/form_objects/post_with_only_existing_comments_form'
require 'support/form_objects/bulk_posts_form'
require 'support/form_objects/bulk_posts_allow_only_existing_form'
require 'support/form_objects/bulk_posts_allow_only_new_form'
require 'support/form_objects/bulk_posts_with_form_objects_form'
require 'support/form_objects/user_and_comments_form'
require 'support/form_objects/user_form'

RSpec.configure do |config|
  #config.treat_symbols_as_metadata_keys_with_true_values = true
  #config.filter_run :current
  
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