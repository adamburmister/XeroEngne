require 'sidekiq/web'
require 'sidetiq/web'

XeroEngine::Engine.routes.draw do

  devise_for :users,
             class_name: "XeroEngine::User", module: :devise,
             path: 'user',
             sign_out_via: [ :get, :post, :delete ],
             controllers: { registrations: "xero_engine/registrations" }

  resources :organisation_memberships, path: :connections do
    member do
      get :expired
    end
  end
  get '/oauth/callback', to: 'organisation_memberships#create'

  resources :billing_transactions, path: 'billing'
  resources :payment_methods, only: [ :create, :destroy ]

  resources :organisations do
    resource :print_settings, path: :settings
  end

  get '/dashboard', to: 'dashboard#index', as: :dashboard

  authenticate :user, lambda { |u| u.email == ENV.fetch('ADMIN_EMAIL') } do
    mount Sidekiq::Web => '/sidekiq-monitoring'
  end
end
