class UsersController < ApplicationController
  
  def index
    load_users
    respond_with(@users)
  end
  
  def show
    load_user
    respond_with(@user)
  end

  def create
    build_user
    save_user
  end

  def update
    load_user
    build_user
    save_user
  end

  def destroy
    load_user
    @user.destroy
    respond_with(@user)
  end

  private

    def authorized_actions_for(user=nil)
      if user.present? && current_user.admin?
        [:index, :show, :create, :update, :destroy]
      else
        []  
      end
    end  

    def load_users
      @users ||= user_scope.to_a
    end

    def load_user
      @user ||= user_scope.find(params[:id])
    end

    def build_user
      @user ||= user_scope.build
      @user.attributes = user_params
    end

    #TODO: rewrite with block?
    def save_user
      new_r = @user.new_record?
      headers ={}
      if @user.save
        headers= ( new_r ? {status: :created, location: user_url(:id => @user.id) } : {status: :ok} )
      end   
      respond_with(@user, headers)
    end

    def user_params
      params[:user] ? params[:user].permit(User.authorized_attributes_for(current_user)) : {}
    end

    def user_scope
      User.all
    end


end


