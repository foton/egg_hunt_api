#RUN SINGLE TEST?  
#rake test TEST=test/models/identity_test.rb TESTOPTS="--name=test_can_be_created_from_auth_without_user -v"

#RUN ALL TESTS IN FILE?
#rake test TEST=test/models/identity_test.rb 

require 'simplecov' #using global config file .simplecov

require "minitest/reporters"
require "support/rake_rerun_reporter"

reporter_options = { color: true, verbose: false, rerun_prefix: "rm -f log/*.log && be" }
Minitest::Reporters.use! [Minitest::Reporters::RakeRerunReporter.new(reporter_options)]


ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'

class ActiveSupport::TestCase
 
  #if there are problems with Foreign Keys when loading fixtures see http://stackoverflow.com/a/28515064/1223501
  fixtures(:users, :coordinates,:locations, :eggs)

  # Add more helper methods to be used by all tests here...
end

def logger
  Rails.logger
end


