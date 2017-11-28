class LoginController < ApplicationController
  def login
  end

  def forgotPassword
  end

  def signup_form
  end

  def signup
  	p "WE ARE TRYING TO SIGNUP"
  	username = params[:username]
  	password = params[:password]
  	email = params[:email]
  	first_name = params[:first_name]
  	last_name = params[:last_name]
  	err = false 

  	if !email.include?('@')
    	flash[:notice] = 'email is not proper format. need @ .edu adress'
		err = true		
  	end

  	if password.length == 0
	  	flash[:notice] = 'password cannot be empty'
	  	err = true	
  	end

  	if username.length == 0
	  	flash[:notice] = 'username cannot be empty'
	  	err = true	
  	end

  	#encoded_url = URI.encode(url)
  	begin
  		if err == true
	  		redirect_to signup_form_path
	    else
	    	response = RestClient.post 'https://gtcollab.herokuapp.com/api/users/', {username: username, password: password, email: email, first_name:
	  		first_name , last_name: last_name }
	    	objArray = JSON.parse(response.body)

			username = params[:username]
			password = params[:password]
			flash[:notice] = 'User created. You may proceed to login with given credentials '
	    	redirect_to login_path
	    end


  	rescue RestClient::ExceptionWithResponse => err
   		flash[:notice] = 'server could not validate new user. Try again'
   		redirect_to signup_form_path
  	end
  	#flash[:notice] = 'server could not validate new user. Try again'



  end

  def logout
  	$user_id = nil
	$user_name = nil
	$user_first = nil
	$user_last = nil
	$user_email = nil

	flash[:notice] = 'User has logged off'
	redirect_to root_path
  end


  def verify_login # essentually login
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
	    	#p "LOG IN!!!!!!!!"
	    	#p objArray
	    	$user_id = objArray["results"][0]["id"].to_s
	    	$user_name = objArray["results"][0]["username"].to_s
	    	$user_first = objArray["results"][0]["first_name"].to_s
	    	$user_last = objArray["results"][0]["last_name"].to_s
	    	$user_email = objArray["results"][0]["email"].to_s
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
