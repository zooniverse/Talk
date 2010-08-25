Sellers::Application.routes.draw do

  resources :collections do 
    resources :discussions
    
    member do
      post :add
    end
  end
  
  resources :live_collections do
    resources :discussions
  end
  
  resources :comments do
    member do
      post :vote_up
      post :report
    end
    
    collection do
      post :markitup_parser
    end
  end
  
  resources :discussions do
    resources :comments
  end
  
  resources :objects, :controller => :assets do 
    resources :discussions
  end
  
  resources :messages do
    collection do
      get :sent
      get :recipient_search
    end
  end
  
  resources :users do
    resources :messages
    
    member do
      post :report
    end
  end
  
  match '/cas_test' => 'home#cas_test'
  
  match '/admin' => 'admin#index'
  
  root :to => "home#index"  
  
  # mapping for boards 
  match '/science' => 'boards#science'
  match '/help' => 'boards#help'
  match '/chat' => 'boards#chat'
  
  match '/search(.:format)' => 'search#index', :as => :search
  # The priority is based upon order of creation:
  # first created -> highest priority.

  # Sample of regular route:
  #   match 'products/:id' => 'catalog#view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   match 'products/:id/purchase' => 'catalog#purchase', :as => :purchase
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Sample resource route with options:
  #   resources :products do
  #     member do
  #       get :short
  #       post :toggle
  #     end
  #
  #     collection do
  #       get :sold
  #     end
  #   end

  # Sample resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Sample resource route with more complex sub-resources
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get :recent, :on => :collection
  #     end
  #   end

  # Sample resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end

  # You can have the root of your site routed with "root"
  # just remember to delete public/index.html.
  # root :to => "welcome#index"

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id(.:format)))'
end
