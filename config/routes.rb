Rails.application.routes.draw do
  root 'home#index'

  get 'login' => 'sessions#new', :as => :login
  get 'signup' => 'members#new', :as => :signup
  delete 'logout' => 'sessions#destroy', :as => :logout

  resources :errors, only: [:show, :index]
  # resources :members, only: [:index]
  resources :subscribers, only: [:index]
  resources :accounts, only: [:show]
  resources :installations, only: [:show, :index]
  resources :settings, only: [:index]

  mount_devise_token_auth_for "Member", at: 'api/v1/auth', controllers: {
    omniauth_callbacks: 'overrides/omniauth_callbacks'
  }
  namespace :api, defaults: {format: :json} do
    namespace :v1 do
      resources :errors, only: [:create, :index, :show, :update]
      resources :subscribers, only: [:index]
      resources :members, only: [:show]
      resources :websites, only: [:index]
    end
  end
end
