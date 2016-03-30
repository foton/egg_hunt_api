require 'test_helper'
require 'support/requests_helper'
require_relative 'api_setup'

class Api::V1::BaseRequestsTest < ActionDispatch::IntegrationTest

include Api::V1::Setup  
include ::RequestsHelper

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

end
