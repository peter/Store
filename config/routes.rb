ActionController::Routing::Routes.draw do |map|
  map.resources :customers

  map.resources :line_items

  map.resources :orders

  map.resources :menus

  map.resources :contents

  map.resources :products
  map.resources :images
  
  map.with_options(:controller => 'home') do |m|
    m.add_to_cart '/add_to_cart/:id/', :action => 'add_to_cart'
  end
  

  map.with_options(:controller => 'products') do |m|
    m.product_create_comment 'products/:id/create_comment', :action => 'create_comment'
    m.product_create_image 'products/:id/create_image', :action => 'create_image'
  end
  
  map.with_options(:controller => 'home') do |m|
    m.root :action => "index", :controller => "home"
  end

  map.resource :user_session
  map.resources :users
  map.resource :account, :controller => "users"

  map.with_options(:controller => 'user_sessions') do |m|
    m.login 'login', :action => "new"
    m.logout 'logout', :action => "destroy"
  end
  
  map.with_options(:controller => 'images') do |m|
    m.images_ajax_destroy 'images/ajax_destroy/:id', :action => 'ajax_destroy'
  end
  
  map.register 'register', :controller => "users", :action => "new"
end
