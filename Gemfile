source 'https://rubygems.org'

gem 'rails'
gem 'pg' #PostgreSQL
gem 'has_secure_token' #for auth token generation; will be included in Rails 5
#gem 'active_type'  #not yet used, but may be VERY usefull

group :development, :test do

  # Call 'byebug' anywhere in the code to stop execution and get a debugger console
  gem 'byebug'
  gem "pry-rails" # pry instead IRB in rails console
  gem "pry-byebug" #debugging with pry on ruby with commands ('step','next','finish','continue')
  gem "minitest-reporters" #better formatted output of Minitest

  #managing secrets
  gem 'dotenv-rails' #loads secrets from.env file into ENV variables (which are then used in config.secrets.yml)
end

group :development do
  # Access an IRB console on exception pages or by using <%= console %> in views
  gem 'web-console', '~> 2.0'

  # Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
  gem 'spring'
end

group :test do
  gem 'simplecov' # code coverage reports
end

