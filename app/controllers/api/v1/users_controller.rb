class Api::V1::UsersController < Api::V1::ApiController
  
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
      unless defined?(@users)
        @users=user_scope
        sort_users
        filter_users
        limit_users
        restrict_fields
      end  
      @users
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
        headers= ( new_r ? {status: :created, location: api_v1_user_url(:id => @user.id, format: (params[:format] || :json) )) } : {status: :ok} )
      end   
      respond_with(@user, headers)
    end

    def user_params
      params[:user] ? params[:user].permit(User.authorized_attributes_for(current_user)) : {}
    end

    def user_scope
      User.all
    end

    #set sorting according to param "sort=-email,+admin" , "sort=+email", "sort=email"
    def sort_users
      if params[:sort].present?
        params[:sort].split(",").each {|sort_according_to| add_sorting_for(sort_according_to)}
      end  
    end  

    def add_sorting_for(sort_according_to) 
      arr_sort=sort_according_to.split("")
      if arr_sort.first=="-"
        @users=@users.order(" #{arr_sort[1..-1].join("")} DESC")
      elsif arr_sort.first=="+"  
        @users=@users.order(" #{arr_sort[1..-1].join("")} ASC")
      else
        @users=@users.order(" #{sort_according_to} ASC")
      end  
    end

    #filtering selected users accordind to attributes values
    #eg. "/users?admin=true&email=bunny"
    def filter_users
      allowed_keys=["email", "admin"]
      filtering_keys=allowed_keys & params.keys
      filtering_keys.each {|key| filter_by_key(key)}
    end

    def filter_by_key(key)
      case key.to_s
      when "email"  #email=someemail@dot.com
        @users=@users.where("email LIKE ?", "#{params[key]}%")
      when "admin"  
        if ["true", true, "1", 1].include?(params[key])
          @users=@users.admins
        elsif  ["false", false, "0", 0].include?(params[key])
          @users=@users.non_admins
        else
          #do not filter
        end  
      end  
    end  
    
    #restrict returned users according to "limit=5" and "offset=100"
    #no default pagination implemented
    def limit_users
      @users=@users.offset(params[:offset]) if params[:offset].present?
      @users=@users.limit(params[:limit]) if params[:limit].present?
    end  
 
    #restrict returned attributes according to "fields=email,token"
    def restrict_fields

      allowed_fields=User.new.attributes.keys
      @fields=allowed_fields & (params[:fields] || "").split(",")
      if @fields.present?
        @users=@users.select(@fields) 
      else
        @fields=allowed_fields
      end  
    end  

end


