FoodStella::Application.routes.draw do
  devise_for :users, controllers: { sessions: "sessions", registrations: "registrations", omniauth_callbacks: "omniauth_callbacks" }
  get "static_pages/home"

  root "static_pages#home"


  #resources :model defines a number of routes for a model automatically, including create, destroy, edit.  Using member do
  #adds a restul route that I define here as "dashboard"
  resources :users do
    member do
      get 'dashboard'
      get 'calendar'
      get 'inbox'
    end

  end

  resources :recipes

  resources :events do
    collection do 
      get :get_events
      post :move
    end
  end

  resources :friendship do 
    member do
      post 'accept'
      post 'decline'
      post 'delete'
    end
  end



  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  # root 'welcome#index'

  # Example of regular route:
  #   get 'products/:id' => 'catalog#view'

  # Example of named route that can be invoked with purchase_url(id: product.id)
  #   get 'products/:id/purchase' => 'catalog#purchase', as: :purchase

  # Example resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Example resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Example resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Example resource route with more complex sub-resources:
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', on: :collection
  #     end
  #   end
  
  # Example resource route with concerns:
  #   concern :toggleable do
  #     post 'toggle'
  #   end
  #   resources :posts, concerns: :toggleable
  #   resources :photos, concerns: :toggleable

  # Example resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end
end