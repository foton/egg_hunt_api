#RUN SINGLE TEST?  
#rake test TEST=test/models/identity_test.rb TESTOPTS="--name=test_can_be_created_from_auth_without_user -v"

#RUN ALL TESTS IN FILE?
#rake test TEST=test/models/identity_test.rb 

require 'simplecov' #using global config file .simplecov

require "minitest/reporters"
require "support/rake_rerun_reporter"

reporter_options = { color: true, slow_count: 5, verbose: false, rerun_prefix: "rm -f log/*.log && be" }
Minitest::Reporters.use! [Minitest::Reporters::RakeRerunReporter.new(reporter_options)]


ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'

class ActiveSupport::TestCase
  # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
  fixtures :all

  # Add more helper methods to be used by all tests here...
end
