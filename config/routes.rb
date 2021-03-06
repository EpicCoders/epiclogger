Rails.application.routes.draw do
  ActiveAdmin.routes(self)
  root 'home#index'

  get "privacy" => 'home#privacy'
  get 'login' => 'sessions#new', :as => :login
  post 'login' => 'sessions#create'
  get 'signup' => 'users#new', :as => :signup
  post 'signup' => 'users#create'
  delete 'logout' => 'sessions#destroy', :as => :logout
  get '/forgot_password' => 'reset_password#new', as: :forgot_password
  post '/forgot_password' => 'reset_password#create'
  get '/forgot_password/:id' => 'reset_password#edit', as: :reset_password
  patch '/forgot_password/:id' => 'reset_password#update'

  get '/auth/:provider/callback' => 'auth#success'
  resources :auth, as: :auths, only: [:create, :update]

  resources :errors, only: [:show, :index, :update] do
    member do
      post :notify_subscribers
      put  :resolve
      put  :unresolve
    end
  end

  resources :integrations, only: [:update, :destroy] do
    member do
      post :create_task
    end
  end
  resources :websites, only: [:index, :create, :new, :show, :destroy, :update] do
    member do
      get :revoke
      post :change_current
      get :wizard_install
    end
  end
  resources :users, only: [:index, :edit, :update] do
    member do
      get :confirm
    end
  end
  resources :invites, only: [:new, :create] do
    member do
      get :accept
    end
  end
  resources :subscribers, only: [:index, :destroy]
  resources :website_members, only: [:index, :update, :destroy] do
    member do
      put :change_role
    end
  end
  resources :settings, only: [:index]

  resources :website_wizard

  namespace :api, defaults: { format: :json } do
    scope module: 'v1' do
      match '/:id/store' => 'store#create', as: :store, via: [:get, :post]
      match '/:id/release' => 'release#create', as: :release, via: [:post]
    end
  end
end
