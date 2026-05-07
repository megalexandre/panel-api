# frozen_string_literal: true
Rails.application.routes.draw do
  mount Rswag::Api::Engine => '/api-docs'
  mount Rswag::Ui::Engine => '/api-docs'
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
    resources :holidays, only: [:index, :create, :update, :destroy]

  end
  get "up" => "rails/health#show", as: :rails_health_check
end
