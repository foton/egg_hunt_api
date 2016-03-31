require_relative '../requests_test'

class Api::V1::EggRequestsAsAdminTest < Api::V1::RequestsTest

  test("Admin can change egg.user_id") do
  	location=locations(:olomouc)
  	egg_params={name: "My cute egg", size: 1, location_id: location.id, user_id: users(:bunny2).id}
    egg=eggs(:kinder_surprise)
    refute_equal users(:bunny2), egg.user
 
    by_https { patch api_path_to("/eggs/#{egg.id}"), {egg: egg_params },  auth_as(:admin).merge({}) }

    assert_response :ok
    assert_equal 'application/json; charset=utf-8', response.headers['Content-Type']
    assert_equal users(:bunny2).id, response_json['user_id']
  end

  test("Admin can update egg of other user") do
  	location=locations(:olomouc)
  	egg_params={name: "My cute egg", size: 1, location_id: location.id}
    egg=eggs(:kinder_surprise)
    refute_equal users(:admin), egg.user
    eggs_count=Egg.count
 
    by_https { patch api_path_to("/eggs/#{egg.id}"), {egg: egg_params },  auth_as(:admin).merge({}) }

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

  test("Admin can delete egg of other user") do
    egg=eggs(:kinder_surprise)
    refute_equal users(:admin), egg.user
    eggs_count=Egg.count
 
    by_https { delete api_path_to("/eggs/#{egg.id}"), nil,  auth_as(:admin).merge({}) }

    assert_response :ok
    assert_equal 'application/json; charset=utf-8', response.headers['Content-Type']

    assert_equal eggs_count-1, Egg.count
    assert Egg.where(id: egg.id).blank?
    assert_equal egg.to_json, response.body
  end	
  
end
