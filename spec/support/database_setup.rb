ActiveRecord::Base.establish_connection(YAML::load(File.open('config/database.yml'))[ENV["RAILS_ENV"]])
ActiveRecord::Base.logger = Logger.new(File.open('tmp/database.log', 'a'))