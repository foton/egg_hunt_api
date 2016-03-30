require_relative 'requests_test'

class Api::V1::BaseRequestsTest < Api::V1::RequestsTest

  test "Requires HTTPS" do
    get api_path_to("/users"), nil, auth_as(:admin).merge({}) 
    assert_response :redirect
    assert_equal request.url.gsub("http://","https://"), response.headers['Location']

    #following redirect with auth params
    get response.headers['Location'], nil, auth_as(:admin).merge({}) 
    assert_response :ok
  end  
      
  test "It allow sending token in username when using auth in URL" do
    #get "https://username1:password1@www.example.com/api/v1/users.json"
    get "https://www.example.com/api/v1/users.json", nil, {authorization: ActionController::HttpAuthentication::Basic.encode_credentials(users(:admin).token, "blahblah") }
    assert_response :ok
  end

  test "it can figure out format from url extension" do
    skip
  end  

  test "it can figure out format from headers Content Type" do
    skip
  end  

end
