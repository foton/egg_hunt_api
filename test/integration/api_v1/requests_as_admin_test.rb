require 'test_helper'
require 'support/requests_helper'
require_relative 'api_setup'

class Api::V1::RequestsAsAdminTest < ActionDispatch::IntegrationTest

include Api::V1::Setup  
include ::RequestsHelper

  def setup
#    @user=User::AsAdmin.last
#    http_login(@user.username, @user.password)
    
  end  


  #describe "Eggs requests" do

    test("Admin can create egg") { skip }
    test("Admin can update his/her egg") { skip }
    test("Admin can update egg of other user") { skip }
    test("Admin can delete his/her egg") { skip }
    test("Admin can delete his/her of other user") { skip }

  #end

  #describe "Location requests" do

    test("Admin can create location") { skip }
    test("Admin can update location if there are eggs of other users") { skip }
    test("Admin can update location if there are only his/her eggs or none") { skip }
    test("Admin can delete location if there are eggs of other users") { skip }
    test("Admin can delete location if there are only his/her eggs or none") { skip }

  #end  

  #describe "Users request" do
    test("Admin can list users") do
      by_ssl { get api_path_to("/users"), nil, auth_as(:admin).merge({}) }
      assert_response :ok
      assert assigns(:users).present?
      assert_equal 'application/json; charset=utf-8', response.headers['Content-Type']
      assert_equal 3, response_json.size
    end  

    test("Admin can view other user") { skip }
    test("Admin can view his/her own profile") { skip }
    test("Admin can create user") { skip }
    test("Admin can update other user") { skip }
    test("Admin can update his/her profile") { skip }
    test("Admin can delete user") { skip }
  #end  

  
end
