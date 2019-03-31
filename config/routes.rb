Rails.application.routes.draw do
  resources :customers, only: :create
  resources :subscriptions, only: :create
end
