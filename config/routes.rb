Rails.application.routes.draw do
  #get 'payments/index'
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  # root "articles#index"
  resources :payments, only: [:index,:create]
end
