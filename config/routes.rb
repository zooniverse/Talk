Sellers::Application.routes.draw do
  resources :collections do 
    resources :discussions
    
    member do
      post :add
      post :remove
    end
    
    collection do
      get :browse
    end
  end
  
  resources :live_collections do
    resources :discussions
  end
  
  resources :comments do
    member do
      post :vote_up
      post :report
      post :preview
      post :more
    end
    
    collection do
      post :markitup_parser
      get :browse
    end
  end
  
  resources :discussions do
    resources :comments
    
    member do
      post :toggle_featured
    end
    
    collection do
      get :browse
    end
  end
  
  resources :objects, :controller => :assets do 
    resources :discussions
    
    collection do
      get :browse
    end
  end
  
  resources :messages do
    collection do
      post :preview
      get :sent
      get :recipient_search
    end
  end
  
  resources :users do
    resources :messages
    
    member do
      post :report
      post :ban
      post :activate
      post :watch
      post :comments
      post :discussions
    end
  end
  
  resources :boards do
    resources :discussions
    
    collection do
      get :browse
    end
  end
  
  resources :admin do
    member do
      post :ignore
      post :remove_comment
      post :ban
      post :redeem
      post :watch
    end
  end
  
  match '/logout' => 'application#cas_logout'
  
  root :to => "home#index"
  match "/more" => "home#more"
  match "/browse" => "home#browse"
  match "/status" => "home#status"
  
  # mapping for boards
  match "/:board_id/discussions/new" => "discussions#new", :as => :new_board_discussion
  %w(help science chat).each do |board|
    match "/#{board}" => "boards##{board}", :as => "#{board}_board".to_sym
    match "/#{board}/discussions" => "boards##{board}"
    match "/#{board}/discussions/:id" => "discussions#show", :as => "#{board}_board_discussion".to_sym
  end
  
  match '/search(.:format)' => 'search#index', :as => :search
  match '/search/live_collection_results' => 'search#live_collection_results', :as => :live_collection_results
end
