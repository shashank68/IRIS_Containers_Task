Rails.application.routes.draw do
 
  resources :requests
  devise_for :users
  root to: 'shops#index'
  resources :shops
  match 'sale', to: 'shops#sale', via: [:get]
  get '/search' => 'shops#search', :as => 'search_page'
  match 'newrequest', to: 'requests#newrequest', via: [:get]
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
