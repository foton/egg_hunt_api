module AuthHelper 
  def http_login(user = "superFPsekce", password = "Xsekce")
    @request.env['HTTP_AUTHORIZATION'] = ActionController::HttpAuthentication::Basic.encode_credentials(user, password)
  end
end
