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

  test "it can figure out JSON format from url extension" do
    get "https://www.example.com/api/v1/users/#{users(:bunny2).id}.json", nil, {authorization: ActionController::HttpAuthentication::Basic.encode_credentials(users(:admin).token, "blahblah") }
    assert_equal 'application/json; charset=utf-8', response.headers['Content-Type']
    assert_equal users(:bunny2).id, response_json['id']
  end

  test "it can figure out XML format from url extension" do
    get "https://www.example.com/api/v1/users/#{users(:bunny2).id}.xml", nil, {authorization: ActionController::HttpAuthentication::Basic.encode_credentials(users(:admin).token, "blahblah") }
    assert_equal 'application/xml; charset=utf-8', response.headers['Content-Type']
    assert_equal users(:bunny2).id, response_xml['user']['id']
  end  

  test "it can figure out JSON format headers Content Type, if there is no extension" do
    headers={authorization: ActionController::HttpAuthentication::Basic.encode_credentials(users(:admin).token, "blahblah") }
    headers['HTTP_ACCEPT'] = 'application/json'
    headers['CONTENT_TYPE'] = 'application/json'

    get "https://www.example.com/api/v1/users/#{users(:bunny2).id}", nil, headers

    assert_equal 'application/json; charset=utf-8', response.headers['Content-Type']
    assert_equal users(:bunny2).id, response_json['id']
  end

  test "it can figure out XML format headers Content Type, if there is no extension" do
    headers={authorization: ActionController::HttpAuthentication::Basic.encode_credentials(users(:admin).token, "blahblah") }
    headers['HTTP_ACCEPT'] = 'application/xml'
    headers['CONTENT_TYPE'] = 'application/xml'

    get "https://www.example.com/api/v1/users/#{users(:bunny2).id}", nil, headers

    assert_equal 'application/xml; charset=utf-8', response.headers['Content-Type']
    assert_equal users(:bunny2).id, response_xml['user']['id']
  end  

  test "it give prference to extension over Content Type" do
    headers={authorization: ActionController::HttpAuthentication::Basic.encode_credentials(users(:admin).token, "blahblah") }
    headers['HTTP_ACCEPT'] = 'application/json'
    headers['CONTENT_TYPE'] = 'application/json'

    get "https://www.example.com/api/v1/users/#{users(:bunny2).id}.xml", nil, headers
    #NOT JSON, BUT XML
    assert_equal 'application/xml; charset=utf-8', response.headers['Content-Type']
    assert_equal users(:bunny2).id, response_xml['user']['id']
  end


end
