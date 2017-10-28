Rails.application.routes.draw do 
	get '/login', to: 'login#verify_login'

	root 'login#login'
	resources :groups
	resources :meetings
	resources :courses
 
end
