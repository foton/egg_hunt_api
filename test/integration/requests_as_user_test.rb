require 'test_helper'
require 'authentication_helper' 

class RequestsAsGuestTest < ActionDispatch::IntegrationTest
  include AuthHelper

  def setup
 #   @user=User.last
 #   http_login(@user.username, @user.password)
  end  

 # describe "Eggs requests" do

    test "User get his/her own eggs list" do
      skip
    end  

    test "User get his/her egg" do
      skip
    end

    test "User can create egg"
    test "User can update his/her egg"
    test "User can delete his/her egg"

#  end

  #describe "Location requests" do

    test "User can create location"
    test "User cannot update location if there are eggs of other users"
    test "User can update location if there are only his/her eggs or none"
    test "User cannot delete location if there are eggs of other users"
    test "User can delete location if there are only his/her eggs or none"

  #end  

  #describe "Users request" do
    test "User cannot list users"
    test "User cannot view other user"
    test "User can view his/her own profile"
    test "User cannot create user"
    test "User cannot update other user"
    test "User can update his/her profile"
    test "User cannot delete user"
  #end  
  
end
