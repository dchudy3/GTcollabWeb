class LoginController < ApplicationController
  def login
  end

  def forgotPassword
  end

  def signup
  end
  def verify_login
# curl --request POST \
#   --url 'https://secure-headland-60131.herokuapp.com/api/api-token-auth/' \
#   --form 'username=user10' \
#   --form 'password=user10'
	begin
		username = params[:username]
		password = params[:password]

		# to get authorization token #curl --data "username=user10&password=user10" https://secure-headland-60131.herokuapp.com/api/api-token-auth/
	  	response = RestClient.post 'https://gtcollab.herokuapp.com/api/api-token-auth/', {username: username, password: password}
	    objArray = JSON.parse(response.body)
	    p objArray
	    p "INTO uservalidate we go"
	    if response.code == 200 #OK request
	    	#puts objArray
	    	$token = "Token " + objArray["token"]
	    	#p "hello?"
			response = RestClient.get 'https://gtcollab.herokuapp.com/api/users/?username=' + username, {authorization: $token}
	    	#p "we got here?"
	    	objArray = JSON.parse(response.body)
	    	3p objArray
	    	$user_id = objArray["results"][0]["id"].to_s
	    	#p $user_id
	    	#p $user_id.class
	    	#puts $user_id
	    	#puts $token
	    	redirect_to courses_path
	   	else 
	   		flash[:notice] = 'User was not found, try again'
	   		redirect_to root_path
	   	end
	rescue RestClient::ExceptionWithResponse => err
   		flash[:notice] = 'User was not found, try again'
   		redirect_to root_path
  	end
  end
end
