require 'test_helper'
require 'support/authentication_helper' 
require 'support/requests_helper'
require 'support/api/v1/api_setup'

class Api::V1::ApiControllerTest < ActionController::TestCase
  include ControllersAuthHelper
  include ::RequestsHelper
  include Api::V1::Setup  


  private
    def assert_kicked_off(method, action, role, params={})
    	send(method, action, params.merge({format: api_format}))
      assert_response :forbidden, "Call '#{method} #{action}' by :#{role} was not kicked off "
      assert assigns(:users).nil?, "Call '#{method} #{action}' by :#{role} set users!"
      assert assigns(:user).nil?, "Call '#{method} #{action}' by :#{role} set user!"
    end 	

    def assert_allowed_to_do(method, action, role, params={})
      send(method, action, params.merge({format: api_format}))
      case action
      when :index
         assert_response :ok, "Response to call '#{method} #{action}' by :#{role} was not :ok"        
         assert assigns(:users).present?
      when :create   
         assert_response :created, "Response to call '#{method} #{action}' by :#{role} was not :created"        
         assert assigns(:user).present?
      else 
         assert_response :ok, "Response to call '#{method} #{action}' by :#{role} was not :ok"        
         assert assigns(:user).present?
      end   
    end  

end