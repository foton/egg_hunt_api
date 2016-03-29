class StaticController < ApplicationController
	
  skip_before_filter :authenticate_user

  def about
  end  
    
  
end
