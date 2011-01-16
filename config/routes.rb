ActionController::Routing::Routes.draw do |map|
  # The priority is based upon order of creation: first created -> highest priority.

  # Sample of regular route:
  #   map.connect 'products/:id', :controller => 'catalog', :action => 'view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   map.purchase 'products/:id/purchase', :controller => 'catalog', :action => 'purchase'
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   map.resources :products
  map.resource :account, :has_one => :medical_history, :member => {:user_buckets => :get, :equipment =>  :get, :billing => :get, :workout_type => :get, :notifications => :get}
  map.resource :sessions, :member => {:sudo => :post, :unsudo => :post}
  map.resource :password
  
  map.plans '/plans', :controller => 'accounts', :action => 'index'
  map.signup '/signup', :controller => 'accounts', :action => 'new'
  map.logout '/logout', :controller => 'sessions', :action => 'destroy'
  map.login '/login', :controller => 'sessions', :action => 'new'
  
  map.forgot_password '/forgot_password', :controller => 'passwords', :action => 'new'
  map.reset_password '/reset_password/:id', :controller => 'passwords', :action => 'edit'
  map.change_password 'account/change_password', :controller => 'passwords', :action => 'edit'
  
  map.thank_you '/thank_you', :controller => 'accounts', :action => 'thank_you'
  
  map.resources :workouts, {
    :member => {  :play => :any,
                  :resume => :get,
                  :comment => :any,
                  :playlist => :get
                  },
    :collection => {:status => :get} 
  }

  map.resources :weight_tracker

  map.resources :foods, :collection => {:auto_complete_for_food_long_desc => :get, :quick_add => :get }
  map.resources :food_log
  map.resources :activity_log
  map.resources :favorite_foods
  map.resources :favorite_activities
  map.resources :subscriptions
  map.resources :welcome

  map.namespace :admin do |admin|
    admin.resources :activities
    admin.resources :exercises
    admin.resources :users, :member => { :medical_history => :get }
    admin.resources :workouts, :member =>{:comment => [:get, :post], :record_note => :get}
    admin.resources :workout_lists, :member => {:update_order => :post}
    admin.resources :exercise_clips
    admin.resources :user_buckets
    admin.resources :workout_skeletons
    admin.resources :freebies
    admin.resources :workout_skeleton_musclegroups, :member => {:update_order => :post}
  end
  # Sample resource route with options:
  #   map.resources :products, :member => { :short => :get, :toggle => :post }, :collection => { :sold => :get }

  # Sample resource route with sub-resources:
  #   map.resources :products, :has_many => [ :comments, :sales ], :has_one => :seller

  # Sample resource route within a namespace:
  #   map.namespace :admin do |admin|
  #     # Directs /admin/products/* to Admin::ProductsController (app/controllers/admin/products_controller.rb)
  #     admin.resources :products
  #   end
  
  # You can have the root of your site routed with map.root -- just remember to delete public/index.html.
  map.root :controller => "welcome"

  # See how all your routes lay out with "rake routes"

  # Install the default routes as the lowest priority.
  map.connect ':controller/:action/:id'
  map.connect ':controller/:action/:id.:format'
  map.admin 'admin', :controller => 'admin/home', :action => 'index'
end
