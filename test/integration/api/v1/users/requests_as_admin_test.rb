require_relative '../requests_test'

class Api::V1::UserRequestsAsAdminTest < Api::V1::RequestsTest

  test("Admin can list users") do
    by_https { get api_path_to("/users"), nil, auth_as(:admin).merge({}) }

    assert_response :ok
    assert_equal 'application/json; charset=utf-8', response.headers['Content-Type']
    assert_equal 3, response_json.size
    assert_equal [users(:admin), users(:bunny1), users(:bunny2)].to_json, response.body
  end  

  test("User index sorted") do
    by_https { get api_path_to("/users","sort=-email"), nil, auth_as(:admin).merge({}) }

    assert_response :ok
    assert_equal 'application/json; charset=utf-8', response.headers['Content-Type']
    assert_equal 3, response_json.size
    assert_equal User.order("email desc").to_json, response.body
  end  

  test("User index filtered") do
    by_https { get api_path_to("/users","admin=false&email=bunny1"), nil, auth_as(:admin).merge({}) }

    assert_response :ok
    assert_equal 'application/json; charset=utf-8', response.headers['Content-Type']
    assert_equal 1, response_json.size
    assert_equal User.where("email LIKE 'bunny1%'").where(admin: false).to_json, response.body
  end  

  test("User index limited") do
    by_https { get api_path_to("/users","offset=1&limit=1&sort=email"), nil, auth_as(:admin).merge({}) }

    assert_response :ok
    assert_equal 'application/json; charset=utf-8', response.headers['Content-Type']
    assert_equal 1, response_json.size
    assert_equal User.order("email asc").limit(1).offset(1).to_json, response.body
  end  


  test("User index returning only some fields") do
    #skip
    by_https { get api_path_to("/users","fields=email,admin"), nil, auth_as(:admin).merge({}) }

    assert_response :ok
    assert_equal 'application/json; charset=utf-8', response.headers['Content-Type']
    assert_equal 3, response_json.size
    assert_equal User.all.to_json(only: [:email, :admin]), response.body
  end  


  test("Admin can view other user") do
    user=users(:bunny1)

    by_https { get api_path_to("/users/#{user.id}"), nil, auth_as(:admin).merge({}) }

    assert_response :ok
    assert_equal 'application/json; charset=utf-8', response.headers['Content-Type']
    assert_equal user.email, response_json['email']
    assert_equal user.token, response_json['token']
    assert_equal user.admin, response_json['admin']
    assert_equal user.id, response_json['id']
    assert_equal user.created_at, response_json['created_at']
    assert_equal user.updated_at, response_json['updated_at']
    assert_equal user.to_json, response.body
    assert_equal ['email','token','admin','id','created_at','updated_at'].sort, response_json.keys.sort
  end  

  test("Admin can view his/her own profile") do
    user=users(:admin)

    by_https { get api_path_to("/users/#{user.id}"), nil, auth_as(:admin).merge({}) }

    assert_response :ok
    assert_equal 'application/json; charset=utf-8', response.headers['Content-Type']
    assert_equal user.email, response_json['email']
    assert_equal user.token, response_json['token']
    assert_equal user.admin, response_json['admin']
    assert_equal user.id, response_json['id']
    assert_equal user.created_at, response_json['created_at']
    assert_equal user.updated_at, response_json['updated_at']
    assert_equal user.to_json, response.body
  end

  test("Admin can create user") do
    user_params={email: "test@email.cz", token: "willNOTbeOverwritten", admin: false}
    users_count=User.count

    by_https { post api_path_to("/users"), {user: user_params}, auth_as(:admin).merge({}) }

    assert_response :created
    assert_equal 'application/json; charset=utf-8', response.headers['Content-Type']
    assert_equal user_params[:email], response_json['email']
    assert_equal user_params[:token], response_json['token']
    assert_equal user_params[:admin], response_json['admin']
    assert response_json['id'].present?
    assert response_json['created_at'].present?
    assert response_json['updated_at'].present?
    assert_equal "https://www.example.com/api/v1/users/#{response_json['id']}.json", response.headers['Location']

    assert_equal users_count+1, User.count
    assert_equal User.find(response_json['id']).to_json, response.body
    assert_equal ['email','token','admin','id','created_at','updated_at'].sort, response_json.keys.sort
  end

  test("Admin get errors when created user is wrong") do
    user_params={email: "tcz", token: "will be overwritten", admin: false}
    expected_errors={'email' => ["is invalid"] }
    users_count=User.count

    by_https { post api_path_to("/users"), {user: user_params}, auth_as(:admin).merge({}) }

    assert_response :unprocessable_entity
    assert_equal 'application/json; charset=utf-8', response.headers['Content-Type']
    assert_equal expected_errors, response_json['errors']
    assert_equal users_count, User.count
  end
    
  test("Admin can update other user") do
    user_new_params={email: "test@email.cz",  admin: true}
    users_count=User.count
    user=users(:bunny1)

    by_https { patch api_path_to("/users/#{user.id}"), {user: user_new_params} , auth_as(:admin).merge({}) }

    assert_response :ok
    assert_equal 'application/json; charset=utf-8', response.headers['Content-Type']
    assert_equal user_new_params[:email], response_json['email']
    assert_equal user.token, response_json['token'] #token does not change
    assert_equal user_new_params[:admin], response_json['admin']
    assert_equal user.id, response_json['id']
    assert_equal user.created_at, response_json['created_at']
    refute_equal user.updated_at, response_json['updated_at']

    assert_equal users_count, User.count
    user.reload
    assert_equal user.to_json, response.body
    assert_equal ['email','token','admin','id','created_at','updated_at'].sort, response_json.keys.sort
  end

  test("Admin get errors when updating of user go wrong") do
    user_new_params={email: users(:bunny2).email, admin: true}
    user=users(:bunny1)
    updated_at=user.updated_at
    expected_errors={'email' => ["has already been taken"] }

    by_https { patch api_path_to("/users/#{user.id}"), {user: user_new_params} , auth_as(:admin).merge({}) }

    assert_response :unprocessable_entity
    assert_equal 'application/json; charset=utf-8', response.headers['Content-Type']
    assert_equal expected_errors, response_json['errors']
    user.reload
    assert_equal updated_at, user.updated_at
  end

  test("Admin can update his/her profile") do
    user_new_params={email: "test@email.cz", admin: true}
    users_count=User.count
    user=users(:admin)

    by_https { patch api_path_to("/users/#{user.id}"), {user: user_new_params} , auth_as(:admin).merge({}) }
    
    assert_response :ok
    assert_equal 'application/json; charset=utf-8', response.headers['Content-Type']
    assert_equal user_new_params[:email], response_json['email']
    assert_equal user.token, response_json['token'] #token does not change
    assert_equal user_new_params[:admin], response_json['admin']
    assert_equal user.id, response_json['id']
    assert_equal user.created_at, response_json['created_at']
    refute_equal user.updated_at, response_json['updated_at']

    assert_equal users_count, User.count
    user.reload
    assert_equal user.to_json, response.body
    assert_equal ['email','token','admin','id','created_at','updated_at'].sort, response_json.keys.sort
  end

   test("Admin can regenerate user token") do
    user_new_params={token: "regenerate"}
    users_count=User.count
    user=users(:admin)

    by_https { patch api_path_to("/users/#{user.id}"), {user: user_new_params} , auth_as(:admin).merge({}) }

    assert_response :ok
    assert_equal 'application/json; charset=utf-8', response.headers['Content-Type']
    refute_equal user.token, response_json['token'] #token should be regenerated
    assert_equal users_count, User.count
    user.reload
    assert_equal user.to_json, response.body
  end

  test("Admin can delete user, even itself") do
    users_count=User.count
    user=users(:admin)

    by_https { delete api_path_to("/users/#{user.id}"), nil , auth_as(:admin).merge({}) }

    assert_response :ok
    assert_equal 'application/json; charset=utf-8', response.headers['Content-Type']
    assert_equal user.to_json, response.body
    assert_equal users_count-1, User.count
    assert_equal ['email','token','admin','id','created_at','updated_at'].sort, response_json.keys.sort
  end  
  
end
