Rails.application.routes.draw do
  scope module: :v1 do
    resources :customers, only: :create
    resources :subscriptions, only: :create
  end
end
