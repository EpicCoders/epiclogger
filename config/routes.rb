Rails.application.routes.draw do
  ActiveAdmin.routes(self)
  root 'home#index'

  get 'login' => 'sessions#new', :as => :login
  post 'login' => 'sessions#create'
  get 'signup' => 'users#new', :as => :signup
  post 'signup' => 'users#create'
  delete 'logout' => 'sessions#destroy', :as => :logout
  get '/forgot_password' => 'reset_password#new', as: :forgot_password
  post '/forgot_password' => 'reset_password#create'
  get '/forgot_password/:id' => 'reset_password#edit', as: :reset_password
  patch '/forgot_password/:id' => 'reset_password#update'

  get "/auth/:provider/callback" => "omniauth#create"

  resources :errors, only: [:show, :index, :update] do
    member do
      post :notify_subscribers
      put  :resolve
      put  :unresolve
    end
  end
  resources :grouped_issues, only: [:index, :show]
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
  resources :subscribers, only: [:index]
  # resources :accounts, only: [:show]
  resources :installations, only: [:index]
  resources :website_members, only: [:index, :destroy]
  # resources :settings, only: [:index]

  resources :website_wizard

  # mount_devise_token_auth_for 'Member', at: 'api/v1/auth', controllers: {
  #   omniauth_callbacks: 'overrides/omniauth_callbacks'
  # }
  namespace :api, defaults: { format: :json } do
    scope module: 'v1' do
      match '/:id/store' => 'store#create', as: :store, via: [:get, :post]
      match '/:id/release' => 'release#create', as: :release, via: [:post]
    end
  end
  #   namespace :v1 do
  #     resources :errors, only: [:create, :index, :show, :update] do
  #       member do
  #         post :notify_subscribers
  #       end
  #     end
  #     resources :website_members, only: [:index, :destroy]
  #     resources :grouped_issues, only: [:index, :show]
  #     resources :invitations, only: [:create]
  #     resources :subscribers, only: [:index]
  #     resources :members, only: [:show, :create]
  #     resources :websites, only: [:index, :show, :create, :update, :destroy]
  #   end
  # end
end
