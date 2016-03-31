require 'test_helper'
require 'support/requests_helper'
require 'support/api/v1/api_setup'

#parent for other api tests
class Api::V1::RequestsTest < ActionDispatch::IntegrationTest
  include Api::V1::Setup  
  include ::RequestsHelper


  private 
	
	  def assert_kicked_off(role, method, path, params={}, headers={})
      case role
        when :admin
          headers.merge!(auth_as(:admin))
        when :user
          headers.merge!(auth_as(:bunny1))
      end  
    	by_https { send(method, path, params, headers) }
      assert_response :forbidden, "Call '#{method} #{path}' by :#{role} was not kicked off "
      assert assigns(:users).nil?, "Call '#{method} #{path}' by :#{role} set users!"
      assert assigns(:user).nil?, "Call '#{method} #{path}' by :#{role} set user!"
    end 
end  
