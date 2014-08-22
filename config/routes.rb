require 'sidetiq/web'

XeroEngine::Engine.routes.draw do
  devise_for :users, path: 'user', sign_out_via: [ :get, :post, :delete ], :controllers => {:registrations => "xero_engine/registrations"}

  resources :organisation_memberships, path: :connections do
    member do
      get :expired
    end
  end
  get '/oauth/callback', to: 'organisation_memberships#create'

  resources :after_signup, path: 'setup'

  resources :billing_transactions, path: 'billing'
  resources :payment_methods, only: [ :create, :destroy ]

  resources :organisations do
    resource :print_settings, path: :settings
  end

  get '/dashboard', to: 'dashboard#index'
  root :to => "home#index"
end
