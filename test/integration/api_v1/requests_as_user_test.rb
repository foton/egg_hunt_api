require 'test_helper'

class RequestsAsGuestTest < ActionDispatch::IntegrationTest

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

    test("User can create egg") {skip}
    test("User can update his/her egg") {skip}
    test("User can delete his/her egg") {skip}

#  end

  #describe "Location requests" do

    test("User can create location") {skip}
    test("User cannot update location if there are eggs of other users") {skip}
    test("User can update location if there are only his/her eggs or none") {skip}
    test("User cannot delete location if there are eggs of other users") {skip}
    test("User can delete location if there are only his/her eggs or none") {skip}

  #end  

  #describe "Users request" do
    test("User cannot list users") {skip}
    test("User cannot view other user") {skip}
    test("User can view his/her own profile") {skip}
    test("User cannot create user") {skip}
    test("User cannot update other user") {skip}
    test("User can update his/her profile") {skip}
    test("User cannot delete user") {skip}
  #end  
  
end
