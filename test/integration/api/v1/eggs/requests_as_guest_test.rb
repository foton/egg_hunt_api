require_relative '../requests_test'

class Api::V1::EggRequestsAsGuestTest < Api::V1::RequestsTest

  test "Guest can get all eggs" do
    by_https { get api_path_to("/eggs"), nil, nil }
  
    assert_response :ok
    assert_equal 'application/json; charset=utf-8', response.headers['Content-Type']
    assert_equal 6, response_json.size
    assert_equal Egg.all.to_json, response.body
  end

  test "Guest can get all eggs with limit and offset" do
    by_https { get api_path_to("/eggs","offset=2&limit=3"), nil, nil }

    assert_response :ok
    assert_equal 'application/json; charset=utf-8', response.headers['Content-Type']
    assert_equal 3, response_json.size
    assert_equal Egg.offset(2).limit(3).to_json, response.body
  end

  test "Guest can get all eggs sorted by size and placing_time(created_at)" do
    by_https { get api_path_to("/eggs","sort=-size,-created_at"), nil, nil }

    assert_response :ok
    assert_equal 'application/json; charset=utf-8', response.headers['Content-Type']
    assert_equal 6, response_json.size
    assert_equal Egg.order("size DESC, created_at DESC").to_json, response.body
  end

  test "Guest can get all eggs but selected attributes only" do
    by_https { get api_path_to("/eggs","fields=name,created_at"), nil, nil }

    assert_response :ok
    assert_equal 'application/json; charset=utf-8', response.headers['Content-Type']
    assert_equal 6, response_json.size
    assert_equal Egg.all.to_json(only: [:name, :created_at]), response.body
  end


  test "Guest can get all eggs from location" do
    by_https { get api_path_to("/eggs","location_id=#{locations(:olomouc).id}"), nil, nil }

    assert_response :ok
    assert_equal 'application/json; charset=utf-8', response.headers['Content-Type']
    assert_equal 2, response_json.size
    assert_equal Egg.where(location_id: locations(:olomouc).id).to_json, response.body
  end

  test "Guest can get all eggs within area" do
    #area is derived from top-left and bottom-right GPS coordinates
    by_https { get api_path_to("/eggs","area_tl=56.0N,0.3W&area_br=51.5N,9.5E"), nil, nil }
    #this area covers hyde_park and legoland

    assert_response :ok
    assert_equal 'application/json; charset=utf-8', response.headers['Content-Type']
    assert_equal 3, response_json.size
    assert_equal [eggs(:bricked), eggs(:disassembled), eggs(:kinder_surprise)].to_json, response.body
  end

  test "Guest can get all eggs placed after specific time" do
    #disassembled egg is from 2001-01-01
    by_https { get api_path_to("/eggs","created_at>2015-03-03T08:08:08Z"), nil, nil }

    assert_response :ok
    assert_equal 'application/json; charset=utf-8', response.headers['Content-Type']
    assert_equal 5, response_json.size
    assert_equal Egg.where("created_at > ?", "2015-03-03T08:08:08Z").to_json, response.body
  end

  test "Guest can get all eggs from specific user" do
    by_https { get api_path_to("/eggs","user_id=#{users(:bunny2).id}"), nil, nil }

    assert_response :ok
    assert_equal 'application/json; charset=utf-8', response.headers['Content-Type']
    assert_equal 4, response_json.size
    assert_equal Egg.where(user_id: users(:bunny2).id).to_json, response.body
  end  

  test "Guest can get one egg" do
    egg=eggs(:bricked)

    by_https { get api_path_to("/eggs/#{egg.id}"), nil, nil }
    
    assert_response :ok
    assert_equal 'application/json; charset=utf-8', response.headers['Content-Type']
    assert_equal egg.name, response_json['name']
    assert_equal egg.size, response_json['size']
    assert_equal egg.user_id, response_json['user_id']
    assert_equal egg.id, response_json['id']
    assert_equal egg.created_at, response_json['created_at']
    assert_equal egg.updated_at, response_json['updated_at']
    assert_equal egg.to_json, response.body
    assert ['name','size','location_id', 'user_id', 'id','created_at','updated_at'].sort, response_json.keys.sort
  end

  test("Guest cannot create egg") {assert_kicked_off(:guest, :post, api_path_to("/eggs"), {egg: {name: "My cute egg", size: 1, location_id: locations(:legoland).id}}, nil)}
  test("Guest cannot update egg") {assert_kicked_off(:guest, :patch, api_path_to("/eggs/#{eggs(:bricked).id}"), {egg: {name: "My cute egg", size: 1, location_id: locations(:legoland).id}}, nil)}
  test("Guest cannot delete egg") {assert_kicked_off(:guest, :delete, api_path_to("/eggs/#{eggs(:bricked).id}"), nil, nil)}
  
end
