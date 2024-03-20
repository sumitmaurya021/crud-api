Rails.application.routes.draw do
  use_doorkeeper do
    skip_controllers :authorizations, :applications, :authorized_applications
  end

  devise_for :users

  namespace :api do
    namespace :v1 do
      resources :users
      post '/login', to: 'users#login'
      post '/logout', to: 'users#logout'
    end
  end
end
