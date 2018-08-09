require 'sidekiq/web'
require 'sidetiq/web'

Hairillusion::Application.routes.draw do 

  root 'home#index'

  mount Sidekiq::Web => '/sidekiq'
  
  get '/distributors/subregion_options' => 'distributors#subregion_options' 
  get '/set_setting_carriers' => 'distributors#set_setting_carriers' 
  
  post '/add_cart' => 'home#add_cart'
  get '/patent' => 'home#patent'
  get '/get_discount'=> 'home#get_discount'
  get '/update_color'=> 'home#update_color'
  post '/create_order' => 'home#create_order'
  post '/create_club_order' => 'home#create_club_order'
  post '/post_enquiry' => 'home#post_enquiry' 
  
  post '/subscribe' => "home#subscribe"
  get '/payment' => 'home#payment'   
  
  post '/get_shipping_carreirs' =>'home#get_shipping_carreirs'
  get '/get_shipping_states' =>'home#get_shipping_states'
  get '/set_shipping_values' => 'home#set_shipping_values'
    
  get '/edit_card' => 'home#edit_card'   
  post '/update_card' => 'home#update_card'
  get '/videos'=>'home#videos'
  
  get '/apply_in_sixty_seconds' => 'home#apply_in_sixty_seconds'   
  
  post '/create_customer' => 'home#create_customer' 
  post '/process_login' => 'home#process_login'
  
  get '/edit_color' => 'home#edit_color'
  post '/update_color' => 'home#update_color'
  
  
  get '/auto_ship' => 'home#auto_ship'
  get '/account_details' => 'home#account_details'
  get '/past_orders' => 'home#past_orders'
  get '/sign_out' => 'home#sign_out'
  get '/login' => 'home#login'
  get 'dashboard' => 'home#dashboard'
  get '/message_thanks' => 'home#message_thanks' 
  #get '/club_details' => 'home#club_details'
  get '/cart' => 'home#cart'
  get '/checkout' => "home#checkout"
  get '/faq' => 'home#faq'
  get '/thankyou' => 'home#thanks'
  
  get '/edit_address'=> 'home#edit_address'
  post '/update_address'=> 'home#update_address'
  
  get '/product_details' => 'home#product_details'
  get '/remove_product_from_cart' => 'home#remove_product_from_cart'
  get '/get_billing_states' => "home#get_billing_states"
  
  get '/products' => 'home#products'
  post '/order_confirmation' => 'home#after_payment'
  
  post '/confirmation' => 'home#after_payment'
    
  post '/save_forum' => 'home#save_forum' 
  post '/thankyou' => 'home#thankyou'
  get '/buy_now' =>"home#buy_now"
  get '/get_total_price' => 'distributors#get_total_price'
   
  post '/get_forums' => 'home#get_forums' 
  get '/new_forum' => 'home#new_forum' 
  get '/get_states' => 'home#get_states'
  get '/add_to_cart' => 'home#add_to_cart'
  get '/remove_from_cart' => 'home#remove_from_cart'
  get '/fibre_hold' => 'home#fibre_hold'
  
  get '/mirror' => 'home#mirror'
  get '/optimizer' => 'home#optimizer'
  
  get '/forum' => 'home#forum'
  get '/more_reviews' => 'home#more_reviews'  
  
  get '/terms' => 'home#terms'
  get '/testimonials' => 'home#testimonials'
  get '/photos' => 'home#photos'
  get '/how_it_works' => 'home#how_it_works'
  get '/what_is_it' => 'home#what_is_it'
  get '/about_us' => 'home#about_us'
  get '/contact_us' => 'home#contact_us'
  get '/color' => 'home#color'
  get '/mens_hair_loss' => 'home#mens_hair_loss'
  get '/womens_hair_loss' => 'home#womens_hair_loss'

  get '/forgot_password' => 'home#forgot_password'
  post '/forgot_password_email' => 'home#forgot_password_email'
  get '/password_reset_success' => 'home#password_reset_success'
  
  resources :orders, only: [:new, :create, :buy_product] do
    collection do
      get :confirmation
      get :buy_product 
    end
  end
   
  

  resources :distributors, only: [:new, :create] do
    collection do
      get :confirmation
      get :show
      get :edit
      put :update
      post :login
      get :logout
      post :order
      get :past_orders
    end
  end

  resources :health_check, only: [:index]

  namespace :admin do
    get "/" => "orders#index"

    resources :customers, only: [:index, :show, :edit, :update] do
      resources :orders, only: [:index, :new, :create]
    end
     
    resources :forums do
    end 
    
    resources :domain_distributors do
      collection do
        post :filter_report 
        get :download_report 
      end 
    end
    
    resources :distributors, except: [:destroy] do
      resources :orders, only: [:index, :new, :create]

      member do
        get :approve
      end
    end

    resources :orders, except: [:destroy]  do
      member do
        put :refund 
      end
      collection do
        get :pull_details_from_shopify 
        get :distributor_orders
      end
    end

    resources :shipments, except: [:destroy]
  end
end
