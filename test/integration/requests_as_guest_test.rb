require 'test_helper'
 
class RequestsAsGuestTest < ActionDispatch::IntegrationTest
  
  def setup
     load_eggs
  end  

#  describe "Eggs requests" do

    test "Guest can get all eggs" do
      https!
      get "/eggs"
      assert_response :success
      assert assigns(:eggs).present?
    end

    test "Guest can get all eggs with limit and offset" do
      skip  #offset=10&limit=5 
      # To send the total entries back to the user use the custom HTTP header: X-Total-Count.
      # Link: <https://blog.mwaysolutions.com/sample/api/v1/cars?offset=15&limit=5>; rel="next",
      #   <https://blog.mwaysolutions.com/sample/api/v1/cars?offset=50&limit=3>; rel="last",
      #   <https://blog.mwaysolutions.com/sample/api/v1/cars?offset=0&limit=5>; rel="first",
      #   <https://blog.mwaysolutions.com/sample/api/v1/cars?offset=5&limit=5>; rel="prev",

    end

    test "Guest can get all eggs sorted by placing_time" do
      skip  #"sort=-placing_time"
    end

    test "Guest can get all eggs but selected attributes only" do
      skip  #"fields=placing_time,location,size"
    end


    test "Guest can get all eggs from location" do
      skip
    end

    test "Guest can get all eggs within area" do
      #area is derived from top-left and bottom-right GPS coordinates
      skip
    end

    test "Guest can get all eggs placed after specific time" do
      skip
    end

    test "Guest can get all eggs from specific user" do
      skip
    end  

    test "Guest can get one egg" do
      skip
    end

    test "Guest cannot create egg"
    test "Guest cannot update egg"
    test "Guest cannot delete egg"
    
#  end

#  describe "Location requests" do

   
    test "Guest can get all locations" do
      https!
      get "/locations"
      assert_response :success
      assert assigns(:locations).present?
    end

    test "Guest can get all locations with limit and offset" do
      skip  #offset=10&limit=5 
    end

    test "Guest can get all locations sorted by name" do
      skip  #"sort=-placing_time"
    end

    test "Guest can get all locations but selected attributes only" do
      skip  #"fields=name,area,city"
    end

    test "Guest can get all locations within area" do
      #area is derived from top-left and bottom-right GPS coordinates
      skip
    end

    test "Guest can get one location" do
      skip
    end

    test "Guest cannot create location"
    test "Guest cannot update location"
    test "Guest cannot delete location"

#  end  

#  describe "Users request" do
    test "Guest cannot list users"
    test "Guest cannot view user"
    test "Guest cannot create user"
    test "Guest cannot update user"
    test "Guest cannot delete user"
#  end  

end
