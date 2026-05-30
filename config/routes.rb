# frozen_string_literal: true

Rails.application.routes.draw do
  mount Rswag::Api::Engine => "/api-docs"
  mount Rswag::Ui::Engine => "/api-docs"
  scope module: :api do
    post "auth/login"
    post "auth/refresh"
    resources :receivables, only: [ :index, :show, :create, :update, :destroy ] do
      member do
        patch :change_status
      end
    end
    resources :users, only: [ :create ] do
      collection do
        get :me
      end
    end
    post "bordero",           to: "bordero#save"
    get  "bordero",           to: "bordero#index"
    get  "bordero/:id",       to: "bordero#show"
    put  "bordero/:id",       to: "bordero#update"
    get "calendar", to: "calendar#index"
    resources :holidays, only: [ :index, :create, :update, :destroy ]
    namespace :dashboard do
      get :receivables_by_status
      get :summary
    end
  end
  get "up" => "rails/health#show", as: :rails_health_check
end
