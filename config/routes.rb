Rails.application.routes.draw do
  #devise_for :admin_users, ActiveAdmin::Devise.config
  ActiveAdmin.routes(self)
  root 'home#index'

  get 'login' => 'sessions#new', :as => :login
  post 'login' => 'sessions#create'
  get 'signup' => 'users#new', :as => :signup
  post 'signup' => 'users#create'
  delete 'logout' => 'sessions#destroy', :as => :logout

  resources :errors, only: [:show, :index, :update] do
    member do
      post :notify_subscribers
      put  :resolve
    end
  end
  resources :grouped_issues, only: [:index, :show]
  resources :websites, only: [:index, :create, :new, :show, :destroy] do
    member do
      post :change_current
      get :wizard_install
    end
  end
  resources :users, only: [:index, :edit]
  resources :invitations, only: [:new, :show]
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
