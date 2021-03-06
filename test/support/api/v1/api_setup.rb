module Api
  module V1
    module Setup
      
      def api_format
        :json
      end
      
      def api_path_to(resource_path,params_string="")  
        "/api/v1/#{resource_path}.#{api_format}#{params_string.blank? ? "" : "?"+params_string}".gsub("//","/")
      end  

      def auth_as(user)
        user= users(user.to_sym) unless user.kind_of?(User)
        #{"HTTP_AUTHORIZATION" => ActionController::HttpAuthentication::Token.encode_credentials(user.token) }
        {authorization: ActionController::HttpAuthentication::Token.encode_credentials(user.token) }
      end  

      def response_json
        JSON.parse(response.body)
      end

      def response_xml
        Hash.from_xml(response.body)
      end

    end
  end    
end

