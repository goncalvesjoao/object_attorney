$LOAD_PATH.unshift(File.dirname(__FILE__))
$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), "..", "lib"))

ENV["RAILS_ENV"] ||= 'development'

require 'bundler'
Bundler.setup
require "object_attorney"
require 'rspec'
require 'pry'

require_relative 'support/post'
require_relative 'support/post_form'
require_relative 'support/database_setup'

RSpec.configure do |config|
  # config.order = :rand
  I18n.enforce_available_locales = false
end