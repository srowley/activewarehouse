source "http://rubygems.org"

# Specify your gem's dependencies in ..gemspec
gemspec

gem 'adapter_extensions', :git => 'git://github.com/activewarehouse/adapter_extensions.git'
gem 'activewarehouse-etl', :git => 'git://github.com/activewarehouse/activewarehouse-etl.git'

group :development do
  gem "guard-rspec"
end

group :test do
  gem "factory_girl_rails"
  gem 'SystemTimer',  :platform => :mri_18
  gem "database_cleaner", ">= 0.7.2"
  gem "ffaker"
end

group :development, :test do
  gem "sqlite3"
  gem "guard-rspec"
end