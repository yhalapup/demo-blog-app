Rails.application.routes.draw do
  resources :posts, param: :slug do
    resources :comments, only: :create
  end
  root "posts#index"
end
