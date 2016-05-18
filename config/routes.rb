FoodStella::Application.routes.draw do
  post '/rate' => 'rater#create', :as => 'rate'
  devise_for :users, controllers: { sessions: "sessions", registrations: "registrations", omniauth_callbacks: "omniauth_callbacks" }
  get "static_pages/home"
  match 'events/destroy'   => 'events#destroy',    :via => :delete
  match 'events/udpate'   => 'events#update',    :via => :put

  root "static_pages#home"


  #resources :model defines a number of routes for a model automatically, including create, destroy, edit.  Using member do
  #adds a restul route that I define here as "dashboard"
  resources :users do
    member do
      get 'dashboard'
      get 'calendar'
      get 'inbox'
      get 'shopping_list'
      get 'json_list'
      get 'json_list_ing'
      get 'json_list_quant'
    end

    collection do 
      get 'add_day'
      get 'previous_day'
    end

  end

  resources :profiles
  # resources :preferred_foods

  resources :recipes  do
    member do
      get 'sidebar'
    end
  end
  get 'recipes/:page/next_page' => 'recipes#next_page', as: :recipes_next_page
  # get "/recipes/side" => 'recipes#sidebar', as: 'sidebar'
  
  resources :relationships,       only: [:create, :destroy]

  resources :cookeds,       only: [:create, :destroy]

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