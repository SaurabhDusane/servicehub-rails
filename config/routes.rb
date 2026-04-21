require "sidekiq/web"

Rails.application.routes.draw do
  devise_for :users, controllers: {
    registrations: "users/registrations",
    sessions: "users/sessions",
    confirmations: "users/confirmations",
    passwords: "users/passwords"
  }

  authenticate :user, ->(u) { u.admin? } do
    mount Sidekiq::Web => "/sidekiq"
  end

  root "home#index"

  get  "marketplace",       to: "marketplace#index",   as: :marketplace
  get  "marketplace/search", to: "marketplace#search", as: :marketplace_search

  resources :providers, only: %i[show] do
    resources :services, only: %i[show], controller: "provider_services"
    resource  :favorite, only: %i[create destroy], controller: "favorites"
    resources :reviews,  only: %i[index]
    get "availability", to: "availabilities#show"
  end

  namespace :provider do
    resource  :onboarding, only: %i[show update], controller: "onboarding"
    resource  :profile,    only: %i[show edit update]
    resources :services
    resources :availability_windows, except: %i[show]
    resources :availability_exceptions, except: %i[show]
    resources :bookings, only: %i[index show update] do
      member do
        patch :accept
        patch :reject
        patch :mark_completed
        patch :mark_no_show
      end
    end
    resources :reviews, only: %i[index]
    root "dashboard#index"
  end

  namespace :customer do
    resources :bookings, only: %i[index show new create destroy] do
      member do
        patch :cancel
      end
      resource :payment, only: %i[new create], controller: "payments"
      resource :review,  only: %i[new create edit update], controller: "reviews"
    end
    resources :favorites, only: %i[index]
    resources :notifications, only: %i[index] do
      member { patch :read }
      collection { patch :read_all }
    end
    root "dashboard#index"
  end

  namespace :admin do
    root "dashboard#index"
    resources :users,    only: %i[index show update destroy]
    resources :providers, only: %i[index show update]
    resources :bookings, only: %i[index show]
    resources :reviews,  only: %i[index update destroy]
    resources :reports,  only: %i[index show update]
    resources :audit_logs, only: %i[index]
  end

  resources :reports, only: %i[new create]

  post "webhooks/stripe", to: "webhooks/stripe#create"

  get "up", to: "rails/health#show", as: :rails_health_check
end
