Sellers::Application.routes.draw do
  resources :collections do 
    resources :discussions
    
    member do
      post :add
      post :remove
    end
    
    collection do
      get :list_for_browser
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
      get :list_for_discussion
    end
  end
  
  resources :discussions do
    resources :comments
    
    member do
      post :toggle_featured
    end
    
    collection do
      get :list_for_object
      get :list_for_board
      get :list_for_collection
    end
  end
  
  resources :objects, :controller => :assets do 
    resources :discussions
    
    collection do
      get :list_for_browser
    end
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
      get :list_for_browser
    end
  end
  
  match '/cas_test' => 'home#cas_test'
  
  resources :admin do
    member do
      post :ignore
      post :ban
      post :redeem
      post :watch
    end
  end
  
  match '/logout' => 'application#cas_logout'
  
  root :to => "home#index"
  match "/browse" => "home#browse"
  
  match '/home/trending_keywords' => 'home#trending_keywords'
  %w(comments assets objects collections discussions).each do |kind|
    match "/home/trending_#{kind}" => "home#trending_#{kind}"
    match "/home/recent_#{kind}" => "home#recent_#{kind}"
  end
  
  %w(help science chat).each do |board|
    match "/home/recent_#{board}" => "home#recent_#{board}"
  end
  
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
