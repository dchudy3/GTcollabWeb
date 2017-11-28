Rails.application.routes.draw do 
  get 'notifications/show'

	get '/login', to: 'login#verify_login'

	post '/login', to: "login#forgotPassword"
	post '/login', to: "login#signup"

	get '/groups/create'
	get '/groups/new'
	get '/groups/edit'
	get '/groups/joinGroup'
	
	get '/groups/delete', to: "groups#delete" , as: 'group_delete'
	get '/groups/send_invitation', to: "groups#send_invitation" , as: 'group_invitation' 

	post '/groups/create', to: "groups#newGroup"
	post '/groups', to: "groups#editGroup"
	post '/groups/:id', to: "groups#joinGroup"

	get '/groups/send_message', to: "groups#send_message" , as: 'send_group_message' 


	post '/courses/:id', to: "courses#new"

	get '/meetings/new'
	get '/meetings/create'
	get '/meetings/edit'
	get '/meetings/joinMeeting'

	get '/meetings/delete', to: "meetings#delete" , as: 'meeting_delete' 
	get '/meetings/send_invitation', to: "meetings#send_invitation" , as: 'meeting_invitation' 
	


	post '/meetings/create', to: "meetings#newMeeting"
	post '/meetings', to: "meetings#editMeeting"
	post '/meetings/:id', to: "meetings#joinMeeting"
	#get '/courses/'
	#get '/courses/:id/:name/:joined', to: "groups#show"
	root 'login#login'
	get  '/login/logout', to: "login#logout", as: 'logout'
	
	get  '/login/signup_form', to: "login#signup_form", as: 'signup_form'
	get  '/login/signup', to: "login#signup", as: 'signup'

	get '/notification/show', to: "notifications#show" , as: 'notification'
	get '/notification/check', to: "notifications#check"

	resources :groups
	resources :meetings
	resources :courses
 
end
