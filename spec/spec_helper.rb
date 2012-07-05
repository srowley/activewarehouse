require 'rubygems'
require 'active_record'
require 'activewarehouse'
require 'factory_girl_rails'
require 'support/setup'

# Basically stolen from will_paginate's ActiveRecord test setup.
db = ENV['DB'].blank?? 'sqlite3' : ENV['DB']
  
configurations = YAML.load_file(File.expand_path('../config/database.yml', __FILE__))
raise "no configuration for '#{db}'" unless configurations.key? db

configuration = configurations[db]  
ActiveRecord::Base.configurations = { db => configuration }

case db
when "sqlite3"
  #don't need to do anything
when "mysql"
  system "mysql -e 'create database aws_unit;' >/dev/null"
  abort "failed to create mysql database" unless $?.success?
when "postgres"
  system "psql -c 'create database aws_unit;' -U postgres >/dev/null"
  abort "failed to create postgres database" unless $?.success?
else
  raise "database in #{db} environment not created."
end

ActiveRecord::Base.establish_connection(db)

# TODO: figure out why setting tz to UTC breaks one of the SCD specs.
# ActiveRecord::Base.default_timezone = :utc

RSpec.configure do |config|
  # Requires supporting ruby files with custom matchers and macros, etc,
  # in spec/support/ and its subdirectories.
  Dir[("./support/**/*.rb")].each {|f| require f}
      
  config.before(:suite) do
    set_up_classes
    FactoryGirl.reload # Don't think FactoryGirl can register factories for classes until classes exist
  end
  
end



