class ApplicationController < ActionController::Base
  # before_action :redirect_shutdown
  require 'carmen'
  include Carmen
  before_action :set_product_price
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception

  def grid_table_for(resource, params, options = {})
    grid_table = resource.grid_table
    grid_table.populate!(resource, params)

    if block_given?
      yield grid_table.records, grid_table.total_rows
    else
      rows = []

      
      local = options[:local].try(:to_sym) || grid_table.records.klass.name.demodulize.downcase.to_sym
      grid_table.records.each do |record|
        rows << (render_to_string partial: (options[:partial] || 'row'), locals: { local => record })
      end

      render json: { total_rows: grid_table.total_rows, rows: rows }
    end
  end

  private

  def redirect_shutdown
    unless controller_name == 'home' && action_name == 'index'
      redirect_to root_url
    end
  end
    
  def set_product_price
    
    @iphone = true if request.user_agent =~ /iPhone|Mobile|Blackberry|Android/ 

    @price_2x = 76.00
    @price_3x = 114.00
    @price_4x = 152.00
    @price_5x = 190.00
    @price_combo = 76.00
    @laser_price = 249.00
    
    price_row = ProductPrice.first

    @small_price = 0

    @shipping_price = 0
    @recurrent_price = 0
    
    @products = Product.where("product_type = 'normal'")
    
    @spray = @products.where("description='Hair Illusion Fiber Hold Spray'").first
    @price_swo = 55.95
    @price_swof = 92.95
    
    @price_saf = 80.00
    
    @price_2x = @products.where("description='Value Pack 2'").first.try(:price).to_f/100
    @price_3x = @products.where("description='Value Pack 3'").first.try(:price).to_f/100
    @price_4x = @products.where("description='Value Pack 4'").first.try(:price).to_f/100
    @price_5x = @products.where("description='Value Pack 5'").first.try(:price).to_f/100
    @price_combo = @products.where("description='Combo Pack'").first.try(:price).to_f/100 
    @laser_price = @products.where("description='Laser Comb'").first.try(:price).to_f/100
    
    
    @optimizer = @products.where("description='Optimizer'").first
    @mirror = @products.where("description='Mirror'").first
    @wr = @products.where("description='Water Resistant Spray'").first 
    @laser = @products.where("description='Laser Comb'").first
    
    @applicator = @products.where("description='Spray Applicator'").first
    @black_6g = @products.where("description='Black 6g'").first
    
    logger.info ".......................#{@applicator.inspect}"
    @applicator_price = @applicator.price.to_f/100
    
    logger.info @applicator_price.inspect
    
    @small_6g_price = @black_6g.price.to_f/100
     
    if price_row 
      @price_saf = price_row.spray_combo_price/100
      if session[:shipping_price].to_f > 0
        @shipping_price = session[:shipping_price].to_f
      else
        @shipping_price = price_row.shipping_price.to_f
      end

      @price = price_row.price.to_f
      @recurrent_price = price_row.recurrent_price.to_f
      @small_price = price_row.small_product_price.to_f
      @price = 34.95 if @price.to_i == 0
      @small_price = 24.95 if @small_price.to_i == 0
      
      @price_swo = price_row.combo2_price.to_f#55.95
      @price_swof = price_row.combo3_price.to_f 

    else
      @price = 34.95
      @small_price = 24.95
      if session[:shipping_price].to_f > 0
         @shipping_price = session[:shipping_price].to_f 
      else
         @shipping_price = 4.95
      end 
      @recurrent_price = 24.95
    end
  end
  def redirect_shutdown
    unless controller_name == 'home' && action_name == 'index'
      redirect_to root_url
    end
  end
end
