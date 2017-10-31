Rails.application.routes.draw do 
	get '/login', to: 'login#verify_login'

	get '/meetings/new'
	get '/groups/new'

	root 'login#login'
	resources :groups
	resources :meetings
	resources :courses
 
end
