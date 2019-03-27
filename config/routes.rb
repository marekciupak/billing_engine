Rails.application.routes.draw do
  resources :subscriptions, only: :create
end
