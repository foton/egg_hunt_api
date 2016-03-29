require 'test_helper'
require 'support/authentication_helper' 

class RequestsAsAdminTest < ActionDispatch::IntegrationTest
  include AuthHelper
  

  def setup
#    @user=User::AsAdmin.last
#    http_login(@user.username, @user.password)
  end  

  #describe "Eggs requests" do

    test "Admin can create egg"
    test "Admin can update his/her egg"
    test "Admin can update egg of other user"
    test "Admin can delete his/her egg"
    test "Admin can delete his/her of other user"

  #end

  #describe "Location requests" do

    test "Admin can create location"
    test "Admin can update location if there are eggs of other users"
    test "Admin can update location if there are only his/her eggs or none"
    test "Admin can delete location if there are eggs of other users"
    test "Admin can delete location if there are only his/her eggs or none"

  #end  

  #describe "Users request" do
    test "Admin can list users"
    test "Admin can view other user"
    test "Admin can view his/her own profile"
    test "Admin can create user"
    test "Admin can update other user"
    test "Admin can update his/her profile"
    test "Admin can delete user"
  #end  

  
end
