Rails.application.routes.draw do
  # Authentication routes
  get "signup", to: "registrations#new", as: "signup"
  post "signup", to: "registrations#create"
  # config/routes.rb
  # allow GET /login → sessions#new
  get '/login', to: 'sessions#new', as: :login

  resources :sessions, only: %i[new create destroy]
  # …
  # get "login", to: "sessions#new", as: "login"
  # post "login", to: "sessions#create"
  # delete "logout", to: "sessions#destroy", as: "logout"
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Defines the root path route ("/")
  root "home#index"

  # API routes
  namespace :api do
    namespace :v1 do
      resources :journal_entries
      resources :subjects
    end
  end

  # Resource routes
  resources :subjects do
    resources :observations, shallow: true
  end

  # Signup/confirmation and magic link flow
  # Only new/create for magic links:
  resources :magic_links, only: %i[new create]

  # Define a custom "verify" route for the token lookup:
  get "/magic_links/:token", to: "magic_links#verify", as: :verify_magic_link # Your existing session/logout routes
  resources :registrations, only: %i[new create]

end
