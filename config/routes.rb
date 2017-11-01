Rails.application.routes.draw do 
	get '/login', to: 'login#verify_login'
	
	get '/groups/new'
	get '/groups/edit'
	post '/groups', to: "groups#newGroup"
	post '/groups', to: "groups#editGroup"

	get '/meetings/new'
	get '/meetings/edit'
	post '/meetings', to: "meetings#newGroup"
	post '/meetings', to: "meetings#editGroup"

	root 'login#login'
	resources :groups
	resources :meetings
	resources :courses
 
end
