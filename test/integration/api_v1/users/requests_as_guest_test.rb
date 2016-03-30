require_relative '../requests_test'

class Api::V1::UserRequestsAsGuestTest < Api::V1::RequestsTest

  test("Guest cannot list users") { assert_kicked_off(:guest, :get, api_path_to("/users"), nil, nil)}
  test("Guest cannot view other user") {assert_kicked_off(:guest, :get, api_path_to("/users/#{users(:bunny1).id}"), nil, nil)}
  test("Guest cannot create user") {assert_kicked_off(:guest, :post, api_path_to("/users"), {email: "test@email.cz", admin: false}, nil)}
  test("Guest cannot update other user") {assert_kicked_off(:guest, :patch, api_path_to("/users/#{users(:bunny1).id}"), {email: "test@email.cz", admin: false}, nil)}
  test("Guest cannot delete user") {assert_kicked_off(:guest, :delete, api_path_to("/users/#{users(:bunny1).id}"), nil, nil)}
   
end
