# frozen_string_literal: true
Rails.application.routes.draw do
  scope module: :api do
    post "auth/login"
    post "auth/refresh"
      
    resources :receivables, only: [:index, :show, :create, :update, :destroy]
    resources :users, only: [:create] do
      collection do
        get :me
      end
    end
    post "bordero/calculate", to: "bordero#calculate"
  end
  
  get "up" => "rails/health#show", as: :rails_health_check

  
end
