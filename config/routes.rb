Rails.application.routes.draw do
  # Authentication routes
  get "signup", to: "registrations#new", as: "signup"
  post "signup", to: "registrations#create"
  get "login", to: "sessions#new", as: "login"
  post "login", to: "sessions#create"
  delete "logout", to: "sessions#destroy", as: "logout"
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Defines the root path route ("/")
  root "home#index"

  # Resource routes
  resources :subjects do
    resources :observations, shallow: true
  end
  resources :settings

  # API routes
  namespace :api, defaults: { format: :json } do
    namespace :v1 do
      post 'auth/login', to: 'authentication#create'
      delete 'auth/logout', to: 'authentication#destroy'
      
      resources :subjects do
        resources :observations, shallow: true
      end
      resources :settings
    end
  end
end
