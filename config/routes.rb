Rails.application.routes.draw do
  resources :posts, param: :slug do
    resources :comments, only: :create
  end
  root "posts#index"

  require "sidekiq/web"

  mount Sidekiq::Web => "/sidekiq"
end
