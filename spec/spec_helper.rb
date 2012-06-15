require 'rubygems'
require 'active_record'
require 'activewarehouse'
require 'database_cleaner'
require 'factory_girl_rails'

ActiveRecord::Base.establish_connection(:adapter => "sqlite3", :database => ":memory:")

RSpec.configure do |config|
  # Requires supporting ruby files with custom matchers and macros, etc,
  # in spec/support/ and its subdirectories.
  Dir[("./support/**/*.rb")].each {|f| require f}
  
  config.filter = { :new => true }  
  
end



