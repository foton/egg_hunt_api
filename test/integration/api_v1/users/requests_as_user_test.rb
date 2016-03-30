require_relative '../requests_test'

class Api::V1::UserRequestsAsUserTest < Api::V1::RequestsTest

  test("User cannot list users") { assert_kicked_off(:user, :get, api_path_to("/users"), nil, auth_as(:bunny2).merge({}) ) }
  test("User cannot view other user") {assert_kicked_off(:user, :get, api_path_to("/users/#{users(:bunny1).id}"), nil, auth_as(:bunny2).merge({}) ) }
  test("User cannot create user") {assert_kicked_off(:user, :post, api_path_to("/users"), {email: "test@email.cz", bunny2: false}, auth_as(:bunny2).merge({}) ) }
  test("User cannot update other user") {assert_kicked_off(:user, :patch, api_path_to("/users/#{users(:bunny1).id}"), {email: "test@email.cz", bunny2: false}, auth_as(:bunny2).merge({}) ) }
  test("User cannot delete user") {assert_kicked_off(:user, :delete, api_path_to("/users/#{users(:bunny1).id}"), nil, auth_as(:bunny2).merge({}) ) }  

end
