ActionController::Routing::Routes.draw do |map|
  map.resources :products
  map.resources :images
  
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
  map.register 'register', :controller => "users", :action => "new"
end
