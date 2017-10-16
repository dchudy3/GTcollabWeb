Rails.application.routes.draw do
   #'login/login'

  resources :groups
  resources :meetings
  resources :courses
   get 'login/verify_login'
   root 'login#login'
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
