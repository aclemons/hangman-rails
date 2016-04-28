Rails.application.routes.draw do
  root 'static_pages#home'

  get    'help'    => 'static_pages#help'

  resources :games,  only: [ :new, :create, :index, :show ]
  resources :guesses,  only: [ :create, :show ]
end
