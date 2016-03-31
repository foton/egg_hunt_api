require_relative '../requests_test'

class Api::V1::LocationRequestsAsUserTest < Api::V1::RequestsTest
  #should share guest_requests? or some of them?

  test("User can create location") do
    location_params={name: "Gotham bay", city:  "Gotham", top_left_coordinate_str: "50.1N,12.5E", bottom_right_coordinate_str: "50.0N,12.6E"}
    locations_count=Location.count
 
    by_https { post api_path_to("/locations"), {location: location_params },  auth_as(:bunny1).merge({}) }

    assert_response :created
    assert_equal 'application/json; charset=utf-8', response.headers['Content-Type']
    assert_equal location_params[:name], response_json['name']
    assert_equal location_params[:city], response_json['city']
    assert_equal location_params[:description], response_json['description']
    assert_equal users(:bunny1).id, response_json['user_id']
    assert response_json['id'].present?
    assert response_json['created_at'].present?
    assert response_json['updated_at'].present?
    assert_equal "https://www.example.com/api/v1/locations/#{response_json['id']}.json", response.headers['Location']

    assert_equal locations_count+1, Location.count
    assert_equal Location.find(response_json['id']).to_json, response.body
    assert ['name','city','description','id','created_at','updated_at'].sort, response_json.keys.sort
  end  

  test("User cannot update location if there are eggs of other users") do
    skip "Eggs needed"
  end  

  test("User can update location if there are only his/her eggs") do
    skip "Eggs needed"
    location_params={name: "Gotham bay", city:  "Gotham", top_left_coordinate_str: "50.1N,12.5E", bottom_right_coordinate_str: "50.0N,12.6E"}
    location=locations(:hyde_park)
    locations_count=Location.count
 
    by_https { patch api_path_to("/locations/#{location.id}"), {location: location_params },  auth_as(:bunny1).merge({}) }

    assert_response :ok
    assert_equal 'application/json; charset=utf-8', response.headers['Content-Type']
    assert_equal location_params[:name], response_json['name']
    assert_equal location_params[:city], response_json['city']
    assert_equal location_params[:description], response_json['description']
    assert_equal users(:bunny1).id, response_json['user_id']
    assert response_json['id'].present?
    assert response_json['created_at'].present?
    assert response_json['updated_at'].present?

    assert_equal locations_count, Location.count
    assert_equal Location.find(response_json['id']).to_json, response.body
    assert ['name','city','description','id','created_at','updated_at'].sort, response_json.keys.sort
  end  

  test("User can update location if there are no eggs") do
    location_params={name: "Gotham bay", city:  "Gotham", top_left_coordinate_str: "50.1N,12.5E", bottom_right_coordinate_str: "50.0N,12.6E"}
    location=locations(:hyde_park)
    locations_count=Location.count
 
    by_https { patch api_path_to("/locations/#{location.id}"), {location: location_params },  auth_as(:bunny1).merge({}) }

    assert_response :ok
    assert_equal 'application/json; charset=utf-8', response.headers['Content-Type']
    assert_equal location_params[:name], response_json['name']
    assert_equal location_params[:city], response_json['city']
    assert_equal location_params[:description], response_json['description']
    assert_equal users(:bunny1).id, response_json['user_id']
    assert_equal location.id, response_json['id']
    assert_equal location.created_at, response_json['created_at']
    refute_equal location.updated_at, response_json['updated_at']

    assert_equal locations_count, Location.count
    location.reload
    assert_equal location.to_json, response.body
    assert ['name','city','description','id','created_at','updated_at'].sort, response_json.keys.sort
  end  

  test("User cannot delete location if there are eggs of other users") do
    skip "Eggs needed"
  end  

  test("User can delete location if there are only his/her eggs or none") do
    skip "Eggs needed"
  end  

  test("User can delete location if there are no eggs") do
    location=locations(:hyde_park)
    locations_count=Location.count
 
    by_https { delete api_path_to("/locations/#{location.id}"), nil,  auth_as(:bunny1).merge({}) }

    assert_response :ok
    assert_equal 'application/json; charset=utf-8', response.headers['Content-Type']

    assert_equal locations_count-1, Location.count
    assert Location.where(id: location.id).blank?
    assert_equal location.to_json, response.body  #deleted record is returned back
  end 
  
end
