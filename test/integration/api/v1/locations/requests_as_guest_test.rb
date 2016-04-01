require_relative '../requests_test'

class Api::V1::LocationRequestsAsGuestTest < Api::V1::RequestsTest
  
  test "Guest can get all locations" do
    by_https { get api_path_to("/locations"), nil, nil }

    assert_response :ok
    assert_equal 'application/json; charset=utf-8', response.headers['Content-Type']
    assert_equal 3, response_json.size
    assert_equal to_response_json(Location.all), response.body
  end

  test "Guest can get all locations with limit and offset" do
    by_https { get api_path_to("/locations","offset=2&limit=1"), nil, nil }

    assert_response :ok
    assert_equal 'application/json; charset=utf-8', response.headers['Content-Type']
    assert_equal 1, response_json.size
    assert_equal to_response_json(Location.offset(2).limit(1)), response.body
  end

  test "Guest can get all locations sorted by city" do
    by_https { get api_path_to("/locations","sort=-city,+name"), nil, nil }

    assert_response :ok
    assert_equal 'application/json; charset=utf-8', response.headers['Content-Type']
    assert_equal 3, response_json.size
    assert_equal to_response_json(Location.order("city DESC, name ASC")), response.body
  end

  test "Guest can get all locations but selected attributes only" do
    by_https { get api_path_to("/locations","fields=city,name"), nil, nil }

    assert_response :ok
    assert_equal 'application/json; charset=utf-8', response.headers['Content-Type']
    assert_equal 3, response_json.size
    assert_equal to_response_json(Location.all,{only: [:city,:name]}), response.body
  end

  test "Guest can get locations filtered by name" do
    by_https { get api_path_to("/locations","name=L"), nil, nil }

    assert_response :ok
    assert_equal 'application/json; charset=utf-8', response.headers['Content-Type']
    assert_equal 1, response_json.size
    assert_equal to_response_json(Location.where("name LIKE 'L%'")), response.body
  end

  test "Guest can get all locations within area" do
    #area is derived from top-left and bottom-right GPS coordinates
    by_https { get api_path_to("/locations","area_tl=56.0N,0.3W&area_br=51.5N,9.5E"), nil, nil }

    assert_response :ok
    assert_equal 'application/json; charset=utf-8', response.headers['Content-Type']
    assert_equal 2, response_json.size
    assert_equal to_response_json([locations(:hyde_park), locations(:legoland)]), response.body
  end

  test "Guest can get one location" do
    location=locations(:olomouc)

    by_https { get api_path_to("/locations/#{location.id}"), nil, nil }
    debug_response
    assert_response :ok
    assert_equal 'application/json; charset=utf-8', response.headers['Content-Type']
    assert_equal location.name, response_json['name']
    assert_equal location.top_left_coordinate_str, response_json['top_left_coordinate_str']
    assert_equal location.bottom_right_coordinate_str, response_json['bottom_right_coordinate_str']
    assert_equal location.city, response_json['city']
    assert_equal location.description, response_json['description']
    assert_equal location.user_id, response_json['user_id']
    assert_equal location.id, response_json['id']
    assert_equal location.created_at, response_json['created_at']
    assert_equal location.updated_at, response_json['updated_at']
    assert_equal to_response_json(location), response.body
    assert_equal json_response_attributes.sort, response_json.keys.sort
  end

  test("Guest cannot create location") {assert_kicked_off(:guest, :post, api_path_to("/locations"), {location: {name: "Gotham bay", city:  "Gotham", top_left_coordinate: "tlc", bottom_right_coordinate: "brc"}}, nil)}
  test("Guest cannot update location") {assert_kicked_off(:guest, :patch, api_path_to("/locations/#{locations(:legoland).id}"), {location: {name: "Gotham bay", city:  "Gotham"}}, nil)}
  test("Guest cannot delete location") {assert_kicked_off(:guest, :delete, api_path_to("/locations/#{locations(:legoland).id}"),nil, nil)}


  def json_response_attributes
    ['name','top_left_coordinate_str','bottom_right_coordinate_str','city','description', 'user_id', 'id','created_at','updated_at']
  end  

  def to_response_json(obj, options={})
    if options[:only].present?
      opt={only: options[:only] , methods: options[:only]}.merge(options)
    else  
      opt={only: json_response_attributes , methods: json_response_attributes}.merge(options)
    end  
    obj.to_json(opt)
  end  
end
