source 'https://rubygems.org'

# Specify your gem's dependencies in object_attorney.gemspec
gemspec

group :development, :test do
  gem "rspec", "~> 2.11"
  gem "sqlite3"
  gem "activerecord"
  gem 'database_cleaner'
  gem "pry"

  unless ENV["CI"]
    gem "guard-rspec", "~> 0.7"
  end
end
