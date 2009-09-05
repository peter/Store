ActionController::Routing::Routes.draw do |map|
  map.resources :products
  
  map.with_options(:controller => 'home') do |m|
    m.root :action => "index", :controller => "home"
  end
end
