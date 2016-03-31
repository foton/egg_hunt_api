require_relative "../models/exceptions/other_user_eggs_exists.rb"
require_relative "../models/exceptions/user_not_authorized.rb"


class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :null_session
  
  attr_accessor :current_user

  before_filter :authenticate_user
  before_filter :authorize_action

  #---------- Exception handling --------------------
  #First should be common exception and after it there are specific exceptions
  #last "rescue" in chain is evaluated first
  
  rescue_from Exception do |exception|
    begin
      params_to_show= params.to_yaml
    rescue
      params_to_show=params.to_s.encode("utf-8")
    end

    short_version=false
    headers=request.headers.to_s rescue ""
    message=""
    message+="EXCEPTION[#{exception.class.name}]: #{exception}"
    message+="\n CURRENT_USER: #{current_user.to_s}"
    message+="\n PARAMS: #{params_to_show}" unless short_version
    message+="\n REQUEST.BODY: #{request.body.to_s}" unless short_version
    message+="\n FROM:#{ request.remote_ip } \n\n na: #{request.referer}"
    message+="\n QUERY (#{params[:action]}) TO: #{request.url}"
    message+="\n\nPARAMS: #{params_to_show}" unless short_version
    message+="\nHEADERS:#{headers}"
    message+="\n\nBACKTRACE: #{exception.backtrace.join("\n")}" unless short_version
    message+="\n\nEXCEPTION[#{exception.class.name}]: #{exception}"
    logger.error(message)
    puts(message)

    respond_to do |format|
      format.html {
        if Rails.env.include?("development") || Rails.env.include?("test") || (!current_user.blank? && current_user.admin?)
          render text: "#{exception.message} -- #{exception.class}<br/>#{exception.backtrace.join("<br/>")}", status: :internal_server_error
        else
          render file: "#{Rails.root}/public/500", formats: [:html], status: :internal_server_error, layout: false
        end
      }
      format.xml { head :internal_server_error }
      format.json { head :internal_server_error }
      format.js { head :internal_server_error }
    end
  end
  
  rescue_from Exceptions::UserNotAuthorized do |exception|
    msg = exception.message.blank? ? "You are not authorized for this action on this object!" : exception.message
    respond_to do |format|
      format.html { 
        flash[:error]=msg
        redirect_to (request.referer || root_path)
      }
      format.xml { head :forbidden }
      format.json { head :forbidden }
    end
  end

  rescue_from ActiveRecord::RecordNotFound, AbstractController::ActionNotFound do |exception|
    respond_to do |format|
      format.html { render file: "#{Rails.root}/public/404", formats: [:html], status: :not_found }
      format.xml { head :not_found }
      format.json { head :not_found }
    end
  end

  rescue_from Exceptions::OtherUsersEggsExists do |exception|
    respond_to do |format|
      format.html { 
        flash[:error]=exception.message
        redirect_to (request.referer || root_path)
      }
      format.any(:xml, :json) { render( request.format.to_sym => {errors: {eggs: [exception.message]}}, :status => :failed_dependency) }
    end
  end

  def raise_test_exception
    raise "TEST Exception"
  end


  private
    def authenticate_user
      self.current_user=nil
      if request.authorization.present?
        if ActionController::HttpAuthentication::Basic.auth_scheme(request).downcase.strip == "token"
          token, options = ActionController::HttpAuthentication::Token.token_and_options(request)
        else  
          username, password = ActionController::HttpAuthentication::Basic.user_name_and_password(request) 
          token=username
        end  

        usr=User.find_by_token(token)
        if usr.nil? #we have nonexisting token 
          request_http_token_authentication
          #return false
        else  
          self.current_user=usr
        end  

      end  
      true #always return true, for guest current_user is nil
    end
    
    #should be overriden in each controller!
    def authorized_actions_for(user)
      [:raise_test_exception]
    end  

    def authorize_action
      unless authorized_actions_for(current_user).include?(params[:action].to_sym)
        raise Exceptions::UserNotAuthorized.new   
      end  
    end  

    def respond_with(object_s, header_params={})
      
      respond_to do |format|
      #  format.html #render view
        format.any(:xml, :json) { 
          if object_s.respond_to?(:errors) && !object_s.errors.empty?
            render(request.format.to_sym => {errors: object_s.errors}, :status => :unprocessable_entity)
          else  
            render({request.format.to_sym => object_s, :only => @fields}.merge(header_params))
          end  
        }
      end
    end  
end
