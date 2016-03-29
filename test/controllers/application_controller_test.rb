require 'test_helper'

class ApplicationControllerTest < ActionController::TestCase
  
  test "authenticate user if token is present and valid" do
    request.env['HTTP_AUTHORIZATION'] = "Token token=#{users(:bunny1).token}"
    get :raise_test_exception
    assert_response :internal_server_error
    assert assigns(:current_user).present?
    assert_equal users(:bunny1), assigns(:current_user)
  end  
  
  test "authenticate as quest if token is not present" do
    request.env['HTTP_AUTHORIZATION'] = ""
    get :raise_test_exception
    assert_response :internal_server_error
    assert assigns(:current_user).nil?
  end  

  test "return 401 if token is present and not valid" do
    request.env['HTTP_AUTHORIZATION'] = "Token token=1111"
    get :raise_test_exception
    assert_response :unauthorized
    assert assigns(:current_user).nil?
  end  

end  
