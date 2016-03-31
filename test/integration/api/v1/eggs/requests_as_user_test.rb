require_relative '../requests_test'

class Api::V1::EggRequestsAsUserTest < Api::V1::RequestsTest

  test("User can create egg") do
  	location=locations(:legoland)
    egg_params={name: "My cute egg", size: 1, location_id: location.id}
    eggs_count=Egg.count
 
    by_https { post api_path_to("/eggs"), {egg: egg_params },  auth_as(:bunny1).merge({}) }

    assert_response :created
    assert_equal 'application/json; charset=utf-8', response.headers['Content-Type']
    assert_equal egg_params[:name], response_json['name']
    assert_equal egg_params[:size], response_json['size']
    assert_equal location.id, response_json['location_id']
    assert_equal users(:bunny1).id, response_json['user_id']
    assert response_json['id'].present?
    assert response_json['created_at'].present?
    assert response_json['updated_at'].present?
    assert_equal "https://www.example.com/api/v1/eggs/#{response_json['id']}.json", response.headers['Location']

    assert_equal eggs_count+1, Egg.count
    assert_equal Egg.find(response_json['id']).to_json, response.body
    assert_equal ['name','size','location_id','user_id', 'id','created_at','updated_at'].sort, response_json.keys.sort
  end

  test("User get errors when creating bad egg") do
  	location=locations(:legoland)
    egg_params={name: "My cute egg", size: 17, location_id: Location.last.id+1}
    eggs_count=Egg.count
    expected_errors={'size' => ["17 is not a valid size: 1,2,3,4,5,6"], 'location' => ["can't be blank"] } 
 
    by_https { post api_path_to("/eggs"), {egg: egg_params },  auth_as(:bunny1).merge({}) }

    assert_response :unprocessable_entity
    assert_equal 'application/json; charset=utf-8', response.headers['Content-Type']
    assert_equal expected_errors, response_json['errors']
    assert_equal eggs_count, Egg.count
  end

  test("User can update his/her egg") do
  	location=locations(:olomouc)
  	egg_params={name: "My cute egg", size: 1, location_id: location.id}
    egg=eggs(:kinder_surprise)
    assert_equal users(:bunny1), egg.user
    eggs_count=Egg.count
 
    by_https { patch api_path_to("/eggs/#{egg.id}"), {egg: egg_params },  auth_as(:bunny1).merge({}) }

    assert_response :ok
    assert_equal 'application/json; charset=utf-8', response.headers['Content-Type']
    assert_equal egg_params[:name], response_json['name']
    assert_equal egg_params[:size], response_json['size']
    assert_equal location.id, response_json['location_id']
    assert_equal users(:bunny1).id, response_json['user_id']
    assert_equal egg.id, response_json['id']
    assert_equal egg.created_at, response_json['created_at']
    refute_equal egg.updated_at, response_json['updated_at']

    assert_equal eggs_count, Egg.count
    egg.reload
    assert_equal egg.to_json, response.body
    assert_equal ['name','size','location_id','user_id', 'id','created_at','updated_at'].sort, response_json.keys.sort
  end	

  test("user cannot change user_id") do
  	location=locations(:olomouc)
  	egg_params={name: "My cute egg", size: 1, location_id: location.id, user_id: users(:admin).id}
    egg=eggs(:kinder_surprise)
    assert_equal users(:bunny1), egg.user
 
    by_https { patch api_path_to("/eggs/#{egg.id}"), {egg: egg_params },  auth_as(:bunny1).merge({}) }

    assert_response :ok
    assert_equal 'application/json; charset=utf-8', response.headers['Content-Type']
    assert_equal users(:bunny1).id, response_json['user_id']
  end	

  test("User get errors when do bad update of egg") do
  	location=locations(:legoland)
    egg_params={name: "My cute egg", size: 17, location_id: Location.last.id+1}
    eggs_count=Egg.count
    expected_errors={'size' => ["17 is not a valid size: 1,2,3,4,5,6"], 'location' => ["can't be blank"] } 
 
    by_https { post api_path_to("/eggs"), {egg: egg_params },  auth_as(:bunny1).merge({}) }

    assert_response :unprocessable_entity
    assert_equal 'application/json; charset=utf-8', response.headers['Content-Type']
    assert_equal expected_errors, response_json['errors']
    assert_equal eggs_count, Egg.count
  end

  test("User cannot update egg of other user") do
    egg=eggs(:bricked)
    refute_equal users(:bunny1), egg.user
    eggs_count=Egg.count
 
    by_https { patch api_path_to("/eggs/#{egg.id}"), {egg: {} },  auth_as(:bunny1).merge({}) }

    assert_response :forbidden
    assert_equal 'application/json', response.headers['Content-Type']
    assert_equal eggs_count, Egg.count
  end	

  test("User can delete his/her egg") do
    egg=eggs(:kinder_surprise)
    assert_equal users(:bunny1), egg.user
    eggs_count=Egg.count
 
    by_https { delete api_path_to("/eggs/#{egg.id}"), nil,  auth_as(:bunny1).merge({}) }

    assert_response :ok
    assert_equal 'application/json; charset=utf-8', response.headers['Content-Type']

    assert_equal eggs_count-1, Egg.count
    assert Egg.where(id: egg.id).blank?
    assert_equal egg.to_json, response.body
  end

  test("User cannot delete egg of other user") do
    egg=eggs(:bricked)
    refute_equal users(:bunny1), egg.user
    eggs_count=Egg.count
 
    by_https { delete api_path_to("/eggs/#{egg.id}"), nil,  auth_as(:bunny1).merge({}) }

    assert_response :forbidden
    assert_equal 'application/json', response.headers['Content-Type']
    assert_equal eggs_count, Egg.count
  end
 
end
