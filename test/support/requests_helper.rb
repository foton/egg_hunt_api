module RequestsHelper
  def debug_response
    puts("[#{response.response_code}] => response.headers:#{response.headers}")
    puts("[#{response.response_code}] => response.body:\n#{response.body}")
    logger.debug("[#{response.response_code}] => response.headers:#{response.headers}")
    logger.debug("[#{response.response_code}] => response.body:\n#{response.body}")
    #puts("assigns:\n#{assigns.to_s}")
    #puts("assigns-zadosti:\n#{assigns(:zadosti).to_s}")
  end

  def by_https 
    https!(true) #cames from ActionDispatch::Integration::Runner :: integration.session
    yield
    https!(false)  
  end  
  
end
