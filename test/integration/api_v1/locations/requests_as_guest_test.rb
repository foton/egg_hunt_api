require_relative '../requests_test'

class Api::V1::LocationRequestsAsGuestTest < Api::V1::RequestsTest
  
  test "Guest can get all locations" do
    skip
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

  test("Guest cannot create location") {skip}
  test("Guest cannot update location") {skip}
  test("Guest cannot delete location") {skip}


end
