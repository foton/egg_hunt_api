require_relative '../requests_test'

class Api::V1::EggRequestsAsGuestTest < Api::V1::RequestsTest

  test "Guest can get all eggs" do
    skip
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

  test("Guest cannot create egg") {skip}
  test("Guest cannot update egg") {skip}
  test("Guest cannot delete egg") {skip}
  
end
