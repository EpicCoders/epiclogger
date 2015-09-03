Rails.application.routes.draw do
  root 'home#index'

  get 'login' => 'sessions#new', :as => :login
  get 'signup' => 'members#new', :as => :signup
  delete 'logout' => 'sessions#destroy', :as => :logout

  resources :errors, only: [:show, :index]
  resources :websites, only: [:index, :new, :show]
  resources :members, only: [:index]
  resources :invitations, only:[:new, :show]
  resources :subscribers, only: [:index]
  resources :accounts, only: [:show]
  resources :installations, only: [:show, :index]
  resources :settings, only: [:index]

  mount_devise_token_auth_for "Member", at: 'api/v1/auth', controllers: {
    omniauth_callbacks: 'overrides/omniauth_callbacks'
  }
  namespace :api, defaults: {format: :json} do
    namespace :v1 do
      resources :errors, only: [:create, :index, :show, :update] do
        member do
          post :notify_subscribers
        end
        collection do
          get :add_error
        end
      end
      resources :invitations, only: [:create]
      resources :subscribers, only: [:index]
      resources :members, only: [:show, :create, :index, :destroy]
      resources :websites, only: [:index, :create, :destroy, :show]
    end
  end
end
