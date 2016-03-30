require 'test_helper'
require 'support/authentication_helper' 

class Api::V1::UsersControllerTest < ActionController::TestCase
  include ControllersAuthHelper

  def setup
	 @accessed_user=users(:bunny2)
	end

  test "kick off guests on index" do
    assert_kicked_off(:get, :index, :guest)
  end
    
  test "kick off guests on show" do  
    assert_kicked_off(:get, :show, :guest, {id: @accessed_user.id})
  end
    
  test "kick off guests on create" do  
    assert_kicked_off(:post, :create, :guest , {user: {email: "my@email.cz", token: "my_Token_Here", admin: true}})
  end
    
  test "kick off guests on update by PUT" do  
    assert_kicked_off(:put, :update, :guest , { id: @accessed_user.id, user: {email: "my@email.cz", token: "my_Token_Here", admin: true}})
  end
    
  test "kick off guests on update by PATCH" do  
    assert_kicked_off(:patch, :update, :guest , {id: @accessed_user.id, user: {email: "my@email.cz", token: "my_Token_Here", admin: true}})
  end
    
  test "kick off guests on delete" do  
    assert_kicked_off(:delete, :destroy, :guest , {id: @accessed_user.id})
  end  
  
  test "kick off common users on index" do
    set_current_user(users(:bunny1))
    assert_kicked_off(:get, :index, :common_user)
  end
  
  test "kick off common users on show" do
    set_current_user(users(:bunny1))
    assert_kicked_off(:get, :show, :common_user, {id: @accessed_user.id})
  end
  
  test "kick off common users on create" do
    set_current_user(users(:bunny1))
    assert_kicked_off(:post, :create, :common_user , {user: {email: "my@email.cz", token: "my_Token_Here", admin: true}})
  end
  
  test "kick off common users on update by PUT" do
    set_current_user(users(:bunny1))
    assert_kicked_off(:put, :update, :common_user , { id: @accessed_user.id, user: {email: "my@email.cz", token: "my_Token_Here", admin: true}})
  end
  
  test "kick off common users on update by PATCH" do
    set_current_user(users(:bunny1))
    assert_kicked_off(:patch, :update, :common_user , {id: @accessed_user.id, user: {email: "my@email.cz", token: "my_Token_Here", admin: true}})
  end
  
  test "kick off common users on delete" do
    set_current_user(users(:bunny1))
    assert_kicked_off(:delete, :destroy, :common_user , {id: @accessed_user.id})
  end 

  test "let admins do index" do
    set_current_user(users(:admin))
    
    assert_allowed_to_do(:get, :index, :admin)
    
    assert_equal User.count, assigns(:users).size 
  end
  
  test "let admins do show" do
    set_current_user(users(:admin))
    
    assert_allowed_to_do(:get, :show, :admin, {id: @accessed_user.id})
    
    assert_equal @accessed_user , assigns(:user)
  end
  
  test "let admins do create admin" do
    user_count=User.count
    set_current_user(users(:admin))

    assert_allowed_to_do(:post, :create, :admin , {user: {email: "my@email.cz", token: "my_Token_Here", admin: true}})

    user=assigns(:user)
    assert user.persisted?
    refute_equal "my_Token_Here", user.token  #token should not be created manually
    assert_equal "my@email.cz" , user.email
    assert user.admin?
    assert_equal user_count+1, User.count
  end

  test "let admins do create user" do
    user_count=User.count
    set_current_user(users(:admin))
    
    assert_allowed_to_do(:post, :create, :admin , {user: {email: "my2@email.cz", token: "", admin: false}})
    
    user=assigns(:user)
    assert user.persisted?
    assert user.token.present?
    assert_equal 24, user.token.size
    assert_equal "my2@email.cz" , user.email
    refute user.admin?
    assert_equal user_count+1, User.count
  end
  
  test "let admins do update by PUT" do
    user_count=User.count
    set_current_user(users(:admin))
    
    assert_allowed_to_do(:put, :update, :admin , { id: @accessed_user.id, user: {email: "my@email.cz", admin: true}})
    
    user=assigns(:user)
    assert user.persisted?
    assert_equal "my@email.cz" , user.email
    assert_equal @accessed_user.token , user.token
    assert user.admin?
    assert_equal user_count, User.count
  end
  
  test "let admins do update by PATCH" do
    user_count=User.count
    set_current_user(users(:admin))
    
    assert_allowed_to_do(:patch, :update, :admin , {id: @accessed_user.id, user: {email: "my@email.cz", token: "my_Token_Here", admin: false}})
    
    user=assigns(:user)
    assert user.persisted?
    assert_equal "my@email.cz" , user.email
    refute_equal "my_Token_Here", user.token  #token should not be created manually
    refute user.admin?
    assert_equal user_count, User.count
  end
  
  test "let admins do delete" do
    user_count=User.count
    set_current_user(users(:admin))
    
    assert_allowed_to_do(:delete, :destroy, :admin , {id: @accessed_user.id})
    
    assert User.find_by_id(@accessed_user.id).blank?
    assert_equal user_count-1, User.count
  end 

  private
    def assert_kicked_off(method, action, role, params={})
    	send(method, action, params.merge({format: :json}))
      assert_response :forbidden, "Call '#{method} #{action}' by :#{role} was not kicked off "
      assert assigns(:users).nil?, "Call '#{method} #{action}' by :#{role} set users!"
      assert assigns(:user).nil?, "Call '#{method} #{action}' by :#{role} set user!"
    end 	

    def assert_allowed_to_do(method, action, role, params={})
      send(method, action, params.merge({format: :json}))
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
