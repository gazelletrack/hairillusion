class DistributorsController < ApplicationController
  before_action :login_required, only: [:show, :edit, :update]
  #before_action :reset_password_required, except: [:edit, :update, :logout] 
  layout 'application'
  
  def new
    @distributor = Distributor.new
        @error = ""
  end
  
  def subregion_options
    render partial: 'subregion_select'
  end
  
  def set_setting_carriers
    
    shipping_arr = params[:value].split("____")  
    session[:shipping_price] = shipping_arr[0].to_f
    
    
    shipping_code = shipping_arr[1]
    session[:country_shipping_code] = shipping_arr[1] 
    
    @shipping_name = shipping_code
    @shipping = shipping_arr[0].to_f
  end
  

  def get_total_price
    @distributor = Distributor.find params[:distributor_id].to_i
    total_qty = 0
    @total_price = 0
    @shipping = 0 
    params[:products].each do |p|  
      if p[1][:qty].to_i > 0
        total_qty += p[1][:qty].to_i
        dpp = DistributorProductPrice.where("distributor_id=? and distributor_product_id=?", @distributor.id, p[1][:product_id].to_i).first
        if dpp 
          @total_price += (p[1][:qty].to_i * dpp.price)
        end
      end 
    end 
    @total_price = @total_price.round(2)
    if @distributor.country && @distributor.country.downcase == "us"
      @shipping = 25
    else
      @shipping = 50
    end
 
    @subtotal = @total_price 
    @total_price = @total_price + @shipping 
    @total_price = @total_price.round(2)
  end
  
  def create
    @distributor = Distributor.new(distributor_params)
      
    if @distributor.save 
      distributor_products = DistributorProduct.all 
      
      distributor_products.each do |dp|
        price = 0
        if ["Jet Black 38g", "Black 38g", "Dark Brown 38g", "Brown 38g", "Light Brown 38g", "Auburn 38g", "Blonde 38g", "Light Blonde 38g"].include?(dp.name)
          price = 22.50
        elsif ["Jet Black 18g", "Black 18g", "Dark Brown 18g", "Brown 18g", "Light Brown 18g", "Auburn 18g", "Blonde 18g", "Light Blonde 18g"].include?(dp.name)
          price = 15.00
        elsif ["Mirror"].include?(dp.name)
          price = 12.00 
        elsif ["Optimizer"].include?(dp.name)
          price = 2.50  
        elsif ["Fibre Hold Spray"].include?(dp.name)
          price = 12.00  
        elsif ["Spray Applicator"].include?(dp.name)
          price = 20.00
        elsif ["Water Resistant Spray"].include?(dp.name)
          price = 19.00     
        elsif ["Black 6g"].include?(dp.name)
          price = 7.50    
        end  
        distributor_product_price = DistributorProductPrice.create(:distributor_id=>@distributor.id,:distributor_product_id=>dp.id, :price=>price)
      end 
      DistributorMailer.new_distributor_notification(@distributor).deliver! 
      DistributorMailer.new_distributor_admin_notification(@distributor).deliver! 

      redirect_to confirmation_distributors_path
    else
      render new_distributor_path
    end
  end

  def show
    @distributor = current_distributor
    @order = @distributor.orders.build
    @credit_card = CreditCard.new

    DistributorProductPrice.where(:distributor_id=>@distributor.id).each do |p| 
      @order.order_items<< OrderItem.new(product: p.distributor_product, quantity: 0, product_type: 'DistributorProduct')
    end
    
  end

  def edit
    @distributor = current_distributor
  end

  def update
    @distributor = current_distributor

    if @distributor.update_attributes(distributor_params)
      @distributor.update_attribute(:require_password_reset, false)
      redirect_to distributors_path
    else
      render :edit
    end
  end

  def confirmation
  end 

  def login
     @error = ""
    @distributor = Distributor.find_by_email(params[:email])
    if @distributor.present? && @distributor.authenticate(params[:password])
      session[:distributor_id] = @distributor.id
      redirect_to distributors_path
    else
      @distributor = Distributor.new if @distributor.nil?
      @error = "Invalid email or password, Please click forgot password if you forgot your password."  
      render :new
    end
  end

  def logout
    reset_session
    redirect_to '/'
  end

  private
  def distributor_params
    params.require(:distributor).permit(:company_name, :country, :first_name, :last_name, :tax_info, :address1, :address2, :city, :state, :zip, :phone, :email, :password, :password_confirmation)
  end

  def current_distributor
    @current_distributor ||= Distributor.find(session[:distributor_id]) if session[:distributor_id]
  end

  def logged_in?
    current_distributor
  end

  def login_required
    redirect_to new_distributor_path unless logged_in?
  end

  def redirect_to_target_or_default(default, *args)
    redirect_to(session[:return_to] || default, *args)
    session[:return_to] = nil
  end

  def store_target_location
    # don't store the target location for SignUp and Login
    unless request.path == new_distributor_path
      session[:return_to] = request.url if request.get? && request.format == :html
    end
  end

  def reset_password_required
    if logged_in? && current_distributor.require_password_reset
      store_target_location
      redirect_to edit_distributors_path, :alert => 'You must update your password'
    end
  end
end
