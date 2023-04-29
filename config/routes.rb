# frozen_string_literal: true

Rails.application.routes.draw do
  root 'home#index'

  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  # root "articles#index"
  namespace :api do
    namespace :v1 do
      resources :members, only: %i[index create show update destroy]
      resources :projects, only: %i[index create show update destroy]
      resources :teams, only: %i[index create show update destroy]

      post 'authenticate', to: 'authentication#create'
    end
  end
end
