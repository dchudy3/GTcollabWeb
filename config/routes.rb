Rails.application.routes.draw do 
	get '/login', to: 'login#verify_login'

	post '/login', to: "login#forgotPassword"
	post '/login', to: "login#signup"

	get '/groups/create'
	get '/groups/new'
	get '/groups/edit'
	get '/groups/joinGroup'
	
	#post '/groups', to: "groups#newGroup"
	post '/groups', to: "groups#editGroup"
	post '/groups/:id', to: "groups#joinGroup"

	post '/courses/:id', to: "courses#new"

	get '/meetings/new'
	get '/meetings/edit'
	get '/meetings/joinMeeting'
	
	post '/meetings', to: "meetings#newMeeting"
	post '/meetings', to: "meetings#editMeeting"
	post '/meetings/:id', to: "meetings#joinMeeting"
	#get '/courses/'
	#get '/courses/:id/:name/:joined', to: "groups#show"
	root 'login#login'
	
	resources :groups
	resources :meetings
	resources :courses
 
end
