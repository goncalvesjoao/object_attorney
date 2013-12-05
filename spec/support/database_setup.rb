# see: http://iain.nl/testing-activerecord-in-isolation
ActiveRecord::Base.establish_connection adapter: "sqlite3", database: ":memory:"
ActiveRecord::Migrator.up "db/migrate"

# see: http://blog.aizatto.com/2007/05/27/activerecord-migrations-without-rails/
#ActiveRecord::Base.establish_connection(YAML::load(File.open('config/database.yml'))[ENV["RAILS_ENV"]])
#ActiveRecord::Base.logger = Logger.new(File.open('tmp/database.log', 'a'))

# config/database.yml
# test:
#   adapter: sqlite3
#   database: db/test.sqlite3
#   pool: 5
#   timeout: 5000
