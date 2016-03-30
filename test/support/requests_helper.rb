module RequestsHelper
  def debug_response
    puts("response.headers:#{response.headers}")
    puts("response.body:\n#{response.body}")
    logger.debug("response.headers:#{response.headers}")
    logger.debug("response.body:\n#{response.body}")
    #puts("assigns:\n#{assigns.to_s}")
    #puts("assigns-zadosti:\n#{assigns(:zadosti).to_s}")
  end

  def by_ssl 
    https!(true) #cames from ActionDispatch::Integration::Runner :: integration.session
    yield
    https!(false)  
  end  
end
