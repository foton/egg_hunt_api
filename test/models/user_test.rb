require 'test_helper'

class UserTest < ActiveSupport::TestCase

  def setup 
    @common_user=users(:bunny1)
    @admin_user=users(:admin)
    @other_user= users(:bunny2)
  end  

  test "User: allow only valid email" do
    assert @other_user.valid?
    @other_user.email = "mx.cz"
    refute @other_user.valid?

    @other_user.email = ""
    refute @other_user.valid?

    @other_user.email = "@mx.cz"
    refute @other_user.valid?

    @other_user.email = "my@email"
    refute @other_user.valid?

    @other_user.email = "my.very.long@email-at-your-home.cz"
    assert @other_user.valid?
  end  

  test "User: do not allow email duplicates" do
    assert @other_user.valid?
    @other_user.email = @common_user.email
    refute @other_user.valid?
  end  

  test "User: do not allow token duplicates" do
    assert @other_user.valid?
    @other_user.token = @common_user.token
    refute @other_user.valid?
  end 

  test "User: create token if not present" do
    user=User.new(email: "my@email.cz")
    user.save!
    assert (user.token.to_s.length == 24), "Token '#{user.token.to_s}' is not 24 chars long"
   
    token1=user.token
    user.token=User::TOKEN_FOR_REGENERATE
    user.save!
    assert (user.token.to_s.length == 24), "Token '#{user.token.to_s}' is not 24 chars long" 
    refute_equal token1, user.token
  end
    
  test "User: can assign authorized_attributes for admin" do
    atts=User.authorized_attributes_for( User.new(admin: true) )
    assert_equal [:email, :token, :admin], atts
  end  

  test "User: can assign authorized_attributes for common user" do
    atts=User.authorized_attributes_for( @common_user )
    assert_equal [], atts
  end  

  test "User: can assign authorized_attributes for guest" do
    atts=User.authorized_attributes_for( nil )
    assert_equal [], atts
  end  
end
