class HomeController < ApplicationController 
  protect_from_forgery :except => [:thankyou]
  skip_before_filter :verify_authenticity_token
  
  layout :resolve_layout
  
  before_filter :check_logged_in
  
  after_action :allow_iframe
  
  def allow_iframe
    response.headers.delete('X-Frame-Options')
  end
  
  def subscribe
    session[:clicked] = true
    unless params[:email].blank?
      sub = Subscriber.find_by_email params[:email]
      if sub.nil?
        Subscriber.create(:email=>params[:email], :active=>true)
      end
    end
  end
  
  def apply_in_sixty_seconds
    respond_to do |format|
      format.html { render :layout => false } # your-action.html.erb
    end
  end
  
  def get_discount
    session[:discount] = nil 
    coupon = Coupon.where('lower(name) = ?', params[:code].downcase).last 
    session[:discount_code] = nil
 
    @error = ""
    cart_price = 0
    @discount_price = 0 
    
    if coupon
      session[:discount_code] = params[:code]
      if session[:cart_obj] && session[:cart_obj].size > 0  
        session[:cart_obj].each do |d| 
          cart_price += d[:price].to_f
        end 
      end 
      if coupon.discount_type == "percentage"
        session[:discount] = @discount_price = cart_price*(coupon.discount_value/100)
      else
        session[:discount] = @discount_price = coupon.discount_value
      end
    else 
        @error = "coupon not found" 
    end
  end
  
  def index   
    unless session[:clicked]
      session[:clicked] = false
    end
    session[:shipping_price] = nil
    session[:discount_code] = nil
    session[:discount] = nil
    @orderer = Customer.new
    @order = @orderer.orders.build(order_items_attributes: [quantity: 1])
    @credit_card = CreditCard.new
    @distributor = Distributor.new     
  end 
  
  def get_shipping_carreirs
    items = []
    amazon_items = []
    address = {}
    @error = ''
    qty = 0
    
    session[:country_shipping_code] = nil
    session[:shipping_price] = nil
    
    first_name = params[:billing][:shipping_firstname]
    last_name = params[:billing][:shipping_lastname]
    country = params[:billing][:shipping_country]
    state = params[:shipping_value][:state]
    city = params[:billing][:shipping_city]  
    address = params[:billing][:shipping_address]
    address1 = params[:billing][:shipping_address]
    address2 = params[:billing][:shipping_address_2]
    zip = params[:billing][:shipping_zip]
    phone = params[:billing][:shipping_phone]
  
    if session[:cart_obj] && session[:cart_obj].size > 0   
      session[:cart_obj].each_with_index do |d,index|  
        qty +=d[:quantity].to_i  
        
        product = Product.where(:description=>d[:name],:product_type=>'normal').first
        if product
          items << { :sku =>  product.sku, :quantity => d[:quantity], :commercialInvoiceValue => d[:price].to_f, :commercialInvoiceValueCurrency => 'USD'}

          amazon_items << { :SellerSKU =>  product.amazon_sku, :SellerFulfillmentOrderItemId => product.id.to_s, :Quantity => d[:quantity].to_i, :GiftMessage => 'Thank you for ordering hairillusion product'}
 
        else   
          name = d[:name]
          name_array = name.split("-") 
          
          logger.info name_array[0].inspect
          
          
          if name_array[0] == "Combo Pack"
            qty +=2
            product = Product.where(:description=>name_array[1],:product_type=>'normal').first 
            if product
              items << { :sku =>  product.sku, :quantity => d[:quantity], :commercialInvoiceValue => (d[:price].to_f/3)*d[:quantity].to_f, :commercialInvoiceValueCurrency => 'USD'}
              
              amazon_items << { :SellerSKU =>  product.amazon_sku, :SellerFulfillmentOrderItemId => product.id.to_s, :Quantity => d[:quantity].to_i, :GiftMessage => 'Thank you for ordering hairillusion product'}


              product2 = Product.where(:description=>"Hair Illusion Fiber Hold Spray",:product_type=>'normal').first 
              items << { :sku =>  product2.sku, :quantity => d[:quantity], :commercialInvoiceValue => (d[:price].to_f/3)*d[:quantity].to_f, :commercialInvoiceValueCurrency => 'USD'}
              
              amazon_items << { :SellerSKU =>  product2.amazon_sku, :SellerFulfillmentOrderItemId => product2.id.to_s, :Quantity => d[:quantity].to_i, :GiftMessage => 'Thank you for ordering hairillusion product'}


              product3 = Product.where(:description=>"Optimizer",:product_type=>'normal').first 
              items << { :sku =>  product3.sku, :quantity => d[:quantity], :commercialInvoiceValue => (d[:price].to_f/3)*d[:quantity].to_f, :commercialInvoiceValueCurrency => 'USD'}
              
              amazon_items << { :SellerSKU =>  product3.amazon_sku, :SellerFulfillmentOrderItemId => product3.id.to_s, :Quantity => d[:quantity].to_i, :GiftMessage => 'Thank you for ordering hairillusion product'}

            end
          elsif name_array[0] == "Value Pack 2"
            qty +=1 
            product = Product.where(:description=>name_array[1],:product_type=>'normal').first 
            if product
              items << { :sku =>  product.sku, :quantity => d[:quantity]*2, :commercialInvoiceValue => (d[:price].to_f/2)*d[:quantity].to_f, :commercialInvoiceValueCurrency => 'USD'}              
              amazon_items << { :SellerSKU =>  product.amazon_sku, :SellerFulfillmentOrderItemId => product.id.to_s, :Quantity => d[:quantity].to_i*2, :GiftMessage => 'Thank you for ordering hairillusion product'}
            end          
          elsif name_array[0] == "Value Pack 3"
            qty +=2
            product = Product.where(:description=>name_array[1],:product_type=>'normal').first 
            if product
              items << { :sku =>  product.sku, :quantity => d[:quantity]*3, :commercialInvoiceValue => (d[:price].to_f/3)*d[:quantity].to_f, :commercialInvoiceValueCurrency => 'USD'}              
              amazon_items << { :SellerSKU =>  product.amazon_sku, :SellerFulfillmentOrderItemId => product.id.to_s, :Quantity => d[:quantity].to_i*3, :GiftMessage => 'Thank you for ordering hairillusion product'}
            end              
          elsif name_array[0] == "Value Pack 4"
            qty +=3
            product = Product.where(:description=>name_array[1],:product_type=>'normal').first 
            if product
              items << { :sku =>  product.sku, :quantity => d[:quantity]*4, :commercialInvoiceValue => (d[:price].to_f/4)*d[:quantity].to_f, :commercialInvoiceValueCurrency => 'USD'}              
              amazon_items << { :SellerSKU =>  product.amazon_sku, :SellerFulfillmentOrderItemId => product.id.to_s, :Quantity => d[:quantity].to_i*4, :GiftMessage => 'Thank you for ordering hairillusion product'}
            end              
          elsif name_array[0] == "Value Pack 6"
            qty +=3 
              
              product1 = Product.where(:description=>"Spray Applicator",:product_type=>'normal').first 
              items << { :sku =>  product1.sku, :quantity => d[:quantity], :commercialInvoiceValue => (d[:price].to_f/3)*d[:quantity].to_f, :commercialInvoiceValueCurrency => 'USD'}
              amazon_items << { :SellerSKU =>  product1.amazon_sku, :SellerFulfillmentOrderItemId => product1.id.to_s, :Quantity => d[:quantity].to_i, :GiftMessage => 'Thank you for ordering hairillusion product'}

              product1 = Product.where(:description=>"Hair Illusion Fiber Hold Spray",:product_type=>'normal').first 
              items << { :sku =>  product1.sku, :quantity => d[:quantity], :commercialInvoiceValue => (d[:price].to_f/3)*d[:quantity].to_f, :commercialInvoiceValueCurrency => 'USD'}
              amazon_items << { :SellerSKU =>  product1.amazon_sku, :SellerFulfillmentOrderItemId => product1.id.to_s, :Quantity => d[:quantity].to_i, :GiftMessage => 'Thank you for ordering hairillusion product'}

              product1 = Product.where(:description=>name_array[1],:product_type=>'normal').first  
              items << { :sku =>  product1.sku, :quantity => d[:quantity], :commercialInvoiceValue => (d[:price].to_f/3)*d[:quantity].to_f, :commercialInvoiceValueCurrency => 'USD'}
              amazon_items << { :SellerSKU =>  product1.amazon_sku, :SellerFulfillmentOrderItemId => product1.id.to_s, :Quantity => d[:quantity].to_i, :GiftMessage => 'Thank you for ordering hairillusion product'}
 
          elsif name_array[0] == "Value Pack 5"
            qty +=4
            logger.info ",,,,,,,,,,,,,"
            logger.info d.inspect
            
            product = Product.where(:description=>name_array[1],:product_type=>'normal').first 
            if product
              items << { :sku =>  product.sku, :quantity => d[:quantity]*5, :commercialInvoiceValue => (d[:price].to_f/5)*d[:quantity].to_f, :commercialInvoiceValueCurrency => 'USD'}              
              amazon_items << { :SellerSKU =>  product.amazon_sku, :SellerFulfillmentOrderItemId => product.id.to_s, :Quantity => d[:quantity].to_i*5, :GiftMessage => 'Thank you for ordering hairillusion product'}

            end    
          elsif ["Spray, Water resistant, Optimizer-Jet Black 38g Fibre", "Spray, Water resistant, Optimizer-Black 38g Fibre", "Spray, Water resistant, Optimizer-Brown 38g Fibre", "Spray, Water resistant, Optimizer-Dark Black 38g Fibre", "Spray, Water resistant, Optimizer-Light Black 38g Fibre", "Spray, Water resistant, Optimizer-Auburn 38g Fibre", "Spray, Water resistant, Optimizer-Light Blonde 38g Fibre","Spray, Water resistant- Optimizer,Blonde 38g Fibre"].include?( d[:name].to_s )            
            qty +=3
              product1 = Product.where(:description=>"Optimizer",:product_type=>'normal').first 
              items << { :sku =>  product1.sku, :quantity => d[:quantity], :commercialInvoiceValue => (d[:price].to_f/4)*d[:quantity].to_f, :commercialInvoiceValueCurrency => 'USD'}
              amazon_items << { :SellerSKU =>  product1.amazon_sku, :SellerFulfillmentOrderItemId => product1.id.to_s, :Quantity => d[:quantity].to_i, :GiftMessage => 'Thank you for ordering hairillusion product'}

              product2 = Product.where(:description=>"Hair Illusion Fiber Hold Spray",:product_type=>'normal').first 
              items << { :sku =>  product2.sku, :quantity => d[:quantity], :commercialInvoiceValue => (d[:price].to_f/4)*d[:quantity].to_f, :commercialInvoiceValueCurrency => 'USD'}
              amazon_items << { :SellerSKU =>  product2.amazon_sku, :SellerFulfillmentOrderItemId => product2.id.to_s, :Quantity => d[:quantity].to_i, :GiftMessage => 'Thank you for ordering hairillusion product'}

              product3 = Product.where(:description=>"Water Resistant Spray",:product_type=>'normal').first 
              items << { :sku =>  product3.sku, :quantity => d[:quantity], :commercialInvoiceValue => (d[:price].to_f/4)*d[:quantity].to_f, :commercialInvoiceValueCurrency => 'USD'}
              amazon_items << { :SellerSKU =>  product3.amazon_sku, :SellerFulfillmentOrderItemId => product3.id.to_s, :Quantity => d[:quantity].to_i, :GiftMessage => 'Thank you for ordering hairillusion product'}

              product4 = Product.where(:description=>d[:color],:product_type=>'normal').first 
              items << { :sku =>  product4.sku, :quantity => d[:quantity], :commercialInvoiceValue => (d[:price].to_f/4)*d[:quantity].to_f, :commercialInvoiceValueCurrency => 'USD'}
              amazon_items << { :SellerSKU =>  product4.amazon_sku, :SellerFulfillmentOrderItemId => product4.id.to_s, :Quantity => d[:quantity].to_i, :GiftMessage => 'Thank you for ordering hairillusion product'}

          elsif name_array[0] == "Spray, Water resistant, Optimizer"
            qty +=2
              product1 = Product.where(:description=>"Optimizer",:product_type=>'normal').first 
              items << { :sku =>  product1.sku, :quantity => d[:quantity], :commercialInvoiceValue => (d[:price].to_f/3)*d[:quantity].to_f, :commercialInvoiceValueCurrency => 'USD'}
              amazon_items << { :SellerSKU =>  product1.amazon_sku, :SellerFulfillmentOrderItemId => product1.id.to_s, :Quantity => d[:quantity].to_i, :GiftMessage => 'Thank you for ordering hairillusion product'}

              product2 = Product.where(:description=>"Hair Illusion Fiber Hold Spray",:product_type=>'normal').first 
              items << { :sku =>  product2.sku, :quantity => d[:quantity], :commercialInvoiceValue => (d[:price].to_f/3)*d[:quantity].to_f, :commercialInvoiceValueCurrency => 'USD'}
              amazon_items << { :SellerSKU =>  product2.amazon_sku, :SellerFulfillmentOrderItemId => product2.id.to_s, :Quantity => d[:quantity].to_i, :GiftMessage => 'Thank you for ordering hairillusion product'}

              product3 = Product.where(:description=>"Water Resistant Spray",:product_type=>'normal').first 
              items << { :sku =>  product3.sku, :quantity => d[:quantity], :commercialInvoiceValue => (d[:price].to_f/3)*d[:quantity].to_f, :commercialInvoiceValueCurrency => 'USD'}
              amazon_items << { :SellerSKU =>  product3.amazon_sku, :SellerFulfillmentOrderItemId => product3.id.to_s, :Quantity => d[:quantity].to_i, :GiftMessage => 'Thank you for ordering hairillusion product'}

          end 
        end
      end
      
      logger.info "..............."
      logger.info amazon_items.inspect
      logger.info "......................"
      
      if items.size > 0
         address    = { 
            :email    => params[:email],
            :name    => "#{first_name} #{last_name}",
            :company    => "",
            :address1    => address,
            :address2    => address2,
            :address3    => "",
            :city        => city,
            :state       => state,
            :postalCode  => zip,
            :country    =>  country,
            :phone      => phone, 
            :isCommercial    => 0, 
            :isPoBox    => 0
          } 
      end 
      
      if country == "US"  
        
        require "peddler" 
        client = MWS.fulfillment_outbound_shipment(
          primary_marketplace_id: "ATVPDKIKX0DER",
          merchant_id: "A1D4HR9FQLX93E",
          aws_access_key_id: "AKIAJSFSWTEXHLUC4IJQ",
          aws_secret_access_key: "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",
        )    
        amazon_address = {:Name=>"#{first_name} #{last_name}", :Line1=> address1, :Line2=> address2, :City=>city, :StateOrProvinceCode=> state, :PostalCode=>zip, :CountryCode=>'US'}
        
        logger.info amazon_items.inspect
        logger.info amazon_address.inspect
        
        begin 
          result = client.get_fulfillment_preview(amazon_address, amazon_items, opts = {}).parse  
          
          if result["FulfillmentPreviews"]["member"]
            setup_amazon_carriers(result["FulfillmentPreviews"]["member"])
          else 
            setup_shipwire_carriers(items, address, qty)
          end  
        rescue
          @error = "Please make sure you have entered valid address"
        end
       
       if !@carriers || @carriers.size == 0
          @error = '' 
          begin
            setup_shipwire_carriers(items, address, qty) 
          rescue
            @error = "Please make sure you have entered valid address"
          end
        end
      else
        setup_shipwire_carriers(items, address, qty)
      end   
    end 
  end
  
  def get_shipping_states
    session[:country_shipping_code] = nil
    session[:shipping_price] = nil
  end
  
  def set_shipping_values
    shipping_arr = params[:value].split("____")  
    session[:shipping_price] = shipping_arr[0].to_f
    shipping_code = shipping_arr[1]
    session[:country_shipping_code] = shipping_arr[1] 
    
    logger.info ".........>"
    logger.info session[:order_id]
    
  end
  
  def get_billing_states 
    
    cc= CountryPrice.where(:country_code=>params[:parent_region]).last   
    if cc 
      @shipping_price = session[:shipping_price] = cc.price
      if !session[:product_cart].nil? && session[:product_cart][:type] != "recurrent" 
        if session[:product_cart][:products][0][:tax] != @shipping_price 
          session[:product_cart][:products][0][:tax] = @shipping_price
        end 
      end
    else
      price_row = ProductPrice.first
      if price_row
        @shipping_price = price_row.shipping_price.to_f
      else
        @shipping_price = 0
      end  
    end 
    
    sub_total = 0
    if session[:cart_obj] && session[:cart_obj].size > 0  
        session[:cart_obj].each do |d| 
          sub_total += d[:price].to_f
        end 
      end 
      
      price = 0.0
    total_qty = 0
    product_count = 0
    value_count = 0
    if session[:cart_obj] && session[:cart_obj].size > 0   
        session[:cart_obj].each do |s|  
          if s[:name].include? "-"
            name = s[:name].split("-")[0] 
            product = Product.where(:description=>name).first 
            if product
              value_count += s[:quantity].to_i
              price += product.shipping_price.to_f/100*s[:quantity]
            end
          else
            product_count += s[:quantity].to_i
          end
        end
    end   
    if value_count == 0 && product_count > 0
      sub_total = sub_total + @shipping_price + (product_count-1)
    elsif product_count > 0  
      #just add 1$ each to other products
      sub_total = sub_total + price + @shipping_price + product_count-1
    else
      sub_total = sub_total + price
    end   
    @ship_price = sub_total
    @shipping_total_price = @shipping_price + (product_count-1)
  end
  
  def edit_card
    if session[:customer_id]
      @customer = Customer.find session[:customer_id].to_i
       if @customer
        @customer_card = CustomerCard.find_by_customer_id @customer.id
      end 
    else
      redirect_to '/'
    end
  end
  
  def update_color
    order = Order.find params[:order_id].to_i
    order_item = order.order_items.first
    
    order_item.product_id = params[:code].to_i
    order_item.save(:validate=>false)
    order.warning_sent = false
    order.card_error = false
    order.save
    
  end
  
  def edit_color
    logger.info session[:customer_id].inspect
    if session[:customer_id]
      @customer = Customer.find session[:customer_id].to_i
      @order = @customer.orders.where(:order_type=>"recurrent", :cancelled=>false).find params[:id].to_i
      
      logger.info @customer.inspect
      logger.info @order.inspect
      
      unless @customer && @order 
          redirect_to '/'
      end 
    else
      redirect_to '/'
    end
  end
  
  def post_enquiry
    OrderMailer.send_enquiry(params).deliver!
    redirect_to '/message_thanks'
  end 
  
  def dashboard
    if session[:customer_id]
      @customer = Customer.find session[:customer_id]
      if @customer
        @customer_card = CustomerCard.find_by_customer_id @customer.id
      end 
    end
  end
  
  def edit_address
    if @customer
        @customer_card = CustomerCard.find_by_customer_id @customer.id
      end
  end
  
  def update_address 
    @error = "Address updation failed"
    if @customer 
      customer = @customer
      customer.first_name = params[:billing][:first_name]
      customer.last_name = params[:billing][:last_name]
      customer.country = params[:billing][:country]
      customer.state = params[:billing][:state]
      
      customer.address1 = params[:billing][:address]
      customer.address2 = params[:billing][:address_2]
      customer.city = params[:billing][:city]
      customer.zip = params[:billing][:zip]
      customer.phone = params[:billing][:phone]
      
      
      customer.billing_first_name = params[:shipping][:first_name]
      customer.billing_last_name = params[:shipping][:last_name]
      customer.billing_country = params[:billing][:shipping_country]
      customer.billing_state = params[:shipment][:state]
      
      customer.billing_address1 = params[:shipping][:address]
      customer.billing_address2 = params[:shipping][:address_2]
      customer.billing_city = params[:shipping][:city]
      customer.billing_zip = params[:shipping][:zip] 
      
      if customer.save!
        @error = ""
        
        @customer = Customer.find session[:customer_id]
        card = CustomerCard.where("customer_id=?",@customer.id).first
        
         @credit_card = CreditCard.new(:name=>params[:customer_card][:card_name], :number=>params[:customer_card][:card_number], :cvc=>params[:customer_card][:ccv],:exp_month=>params[:customer_card][:exp_month],:exp_year=>params[:customer_card][:exp_year])

          if @credit_card.valid? && card 
          
            if card.update_attributes({card_name: params[:customer_card][:card_name], card_number: params[:customer_card][:card_number], ccv:params[:customer_card][:ccv], exp_month:params[:customer_card][:exp_month], exp_year:params[:customer_card][:exp_year]})
              @order = Order.where(:orderer_id=>@customer.id, :orderer_type=>"Customer",:cancelled=>false, :parent_order_id=>nil).last
 
              
              @order.warning_sent = false
              @order.card_error = false
              @order.next_delivery_date = Date.today + 1.days if Date.today >= @order.next_delivery_date if @order.next_delivery_date
              @order.save
              @error = ""
              OrderMailer.card_updated_notification(@customer.id).deliver!                
            end
          else 
            unless @credit_card.valid? 
                @credit_card.errors.messages.each do |p|  
                  @error = @error + p[1][0] + "," 
                end
              end 
        end
    
      else
        @error = customer.errors.full_messages
      end 
    end 
    
  end

  def products

  end
  
  def create_customer
    @error = ""
    @error = "Please enter first name" if params[:first_name].blank?
    @error += "Please enter last name" if params[:last_name].blank? && @error == ""
    @error += "Please enter email" if params[:email].blank? && @error == ""
    if params[:password].length < 8 
      @error += "Password should be minimum 8 digits" if @error == ""
    end
    if params[:password] != params[:password_confirmation]
      @error += "Password doesnt match" if @error == ""
    end 
    
    customer = Customer.find_by_email params[:email]
    @error += "This email already registered. Please login instead" if customer && @error == ""

    @redirect = false 
    @redirect = true if params[:from] = "checkout"
    
    if @error == ""
      customer = Customer.new(:first_name=>params[:first_name], :last_name=>params[:last_name], :email=>params[:email], :password=>params[:password], :address1=> " ", :city=> " ", :state=>" ", :zip=> " ")
      if customer.save(:validate => false)
        OrderMailer.send_signup_notification(customer.id).deliver!
        session[:customer_id] = customer.id
      end
    end 
  end
  
  def sign_out
    session[:customer_id] = nil
    @customer = nil
    redirect_to "/"
  end
  
  def club_details
    
  end
  
  def login
    
  end
  
  def add_cart   
    session[:cart_obj] = Array.new if !session[:cart_obj] 
    position = nil
    product = nil
    qty = 0
    product_type = "normal"
    name = params[:product_type]
    quantity = 1  
    quantity = params[:quantity].to_i if params[:quantity] && params[:quantity].to_i > 1
     
    if( params[:product_type] == "small" || params[:product_type] == "large" )
      name = (params[:product_type] == "small") ? params[:color] + " 18g" : params[:color]
      product = Product.where(:product_type=>"normal",:description=>name).first
    else
      product = Product.where(:product_type=>"normal",:description=>name).first 
    end 
 
    if(params[:product_type] == "c2")  
      product = Product.new(:description=>"Value Pack 2-#{params[:color]}", :price=>@price_2x*100)
      name = "Value Pack 2-#{params[:color]}"
    end
    
    if(params[:product_type] == "swo")  
      product = Product.new(:description=>"Spray, Water resistant, Optimizer", :price=>@price_swo*100)
      name = "Spray, Water resistant, Optimizer"
    end
    
    if(params[:product_type] == "laser")  
      product = Product.new(:description=>"Laser Comb", :price=>@laser_price*100)
      name = "Laser Comb"
    end
    
    if(params[:product_type] == "swof")  
      product = Product.new(:description=>"Spray, Water resistant, Optimizer,#{params[:color]} 38g Fibre", :price=>@price_swof*100)
      name = "Spray, Water resistant, Optimizer-#{params[:color]} 38g Fibre" 
    end
    
    if(params[:product_type] == "c3")  
      product = Product.new(:description=>"Value Pack 3-#{params[:color]}", :price=>@price_3x*100)
      name = "Value Pack 3-#{params[:color]}"
    end
    
    if(params[:product_type] == "c4")  
      product = Product.new(:description=>"Value Pack 4-#{params[:color]}", :price=>@price_4x*100)
      name = "Value Pack 4-#{params[:color]}"
    end
    
    if(params[:product_type] == "c5") 
      product = Product.new(:description=>"Value Pack 5-#{params[:color]}", :price=>@price_5x*100)
      name = "Value Pack 5-#{params[:color]}"
    end
    
    if(params[:product_type] == "combo") 
      product = Product.new(:description=>"Combo Pack-#{params[:color]}", :price=>@price_combo*100)
      name = "Combo Pack-#{params[:color]}"
    end
    
    if(params[:product_type] == "saf")  
      product = Product.new(:description=>"Value Pack 6-#{params[:color]}", :price=>@price_saf*100)
      name = "Value Pack 6-#{params[:color]}"
    end
        
    if product 
      
      if session[:cart_obj].size > 0  
        session[:cart_obj].each_with_index do |d,index|
          if d[:name] == name
            position = index   
          end
        end  
        unless position.nil?  
          session[:cart_obj][position][:quantity] = session[:cart_obj][position][:quantity].to_i + quantity
          qty = qty+ session[:cart_obj][position][:quantity]  
          
          session[:cart_obj][position][:price] = (product.price.to_f/100 * qty) 
          session[:cart_obj][position][:unit_price] = product.price.to_f/100 
        else 
          h = {:product_type =>product_type, :name => name, :unit_price=>product.price.to_f/100 , :product_id => product.id, :quantity => quantity, :price=> (product.price.to_f/100*quantity), :color=>params[:color]}                
          session[:cart_obj] << h 
        end 
      else
        h = {:product_type =>product_type, :name => name, :unit_price=>product.price.to_f/100, :product_id => product.id, :quantity => quantity, :price=> (product.price.to_f/100*quantity), :color=>params[:color]}                
        session[:cart_obj] << h 
      end 
    end   
    
    flash[:notice] = name.to_s+' was added to your shopping cart.!'   
    redirect_to cart_path
  end
  
  def process_login
    @error = ""
    if params[:email] && params[:password]
      customer = Customer.where(:email=>params[:email], :password=>params[:password]).first 
      if customer 
        session[:customer_id] = customer.id
        if customer.country
          
          cc= CountryPrice.where(:country_code=>customer.country).last    
          
          if cc 
            @shipping_price = session[:shipping_price] = cc.price
            if !session[:product_cart].nil? && session[:product_cart][:type] != "recurrent" 
              if session[:product_cart][:products][0][:tax] != @shipping_price 
                session[:product_cart][:products][0][:tax] = @shipping_price
              end 
            end
          else
            price_row = ProductPrice.first
            if price_row
              @shipping_price = price_row.shipping_price.to_f
            else
              @shipping_price = 0
            end  
          end 
        end
      else
        @error = "No matching customer found"
      end
    end
  end
  
  def remove_product_from_cart
    if session[:cart_obj].size > 0  
      session[:cart_obj] = session[:cart_obj].reject { |h| h[:name] == params[:name]  } 
    end
    
    flash[:notice] = params[:name].to_s+' was removed from your shopping cart.!' 
    redirect_to cart_path
  end
  
  def checkout
    logger.info session[:cart_obj].inspect
  end
  
  def cart  
    session[:discount] = nil
  end
  
  def product_details
    if params[:type] == "small"
       
    end 
  end
  
  def create_order    
    shipping_carrier = ''
    if params[:shipment_name].present? 
      shipping_carrier = params[:shipment_name]
    end
    
    @order = nil
    @errors = []
    @err_string = "" 
    shipping_amount = params[:shipping_amount].to_f
    
    if params[:shipment_name].blank?
      @err_string = "Please choose shipping carrier."
    end  
    
    shipping_first_name = params[:first_name_field] rescue ""
    shipping_last_name = params[:last_name_field] rescue ""
    shipping_country = params[:country_field] rescue ""
    shipping_state = params[:state_field] rescue ""
    shipping_address1 = params[:address1_field]  rescue ""
    shipping_address2 = params[:address2_field]  rescue ""
    shipping_city = params[:city_field]  rescue ""
    shipping_phone = params[:phone_field]  rescue ""
    email = params[:email_field] rescue ""
    shipping_zip = params[:zip_field] rescue ""

      first_name = ""
      last_name = ""
      country = ""
      address = ""
      address2 = ""
      city = ""
      state = ""
      zip = ""
      phone = ""
         
    if params[:same_shipping].to_s == "0"
      billing_params = params[:billing] 
      first_name = billing_params[:firstname]
      last_name = billing_params[:lastname]
      country = billing_params[:country]
      address = billing_params[:address]
      address2 = billing_params[:address_2]
      city = billing_params[:city] 
      state = billing_params[:state]
      zip = billing_params[:zip]
      phone = billing_params[:phone]       
      
    end
        
    
    if params[:same_shipping].to_s == "0"
      
      @err_string = "Please enter billing first name" if first_name.blank?
      if last_name.blank?
        @err_string = @err_string + '\n' +"Please enter billing last name" 
      end
      if country.blank?
        @err_string = @err_string + '\n' +"Please select billing country" 
      end
      
      if address.blank?
        @err_string = @err_string + '\n' +"Please enter billing address" 
      end
      
      if city.blank?
        @err_string = @err_string + '\n' +"Please enter billing city" 
      end
      
      if state.blank?
        @err_string = @err_string + '\n' +"Please select billing state" 
      end
      
      if zip.blank?
        @err_string = @err_string + '\n' +"Please enter billing zip" 
      end
      
      if phone.blank?
        @err_string = @err_string + '\n' +"Please enter billing state" 
      end
      
      if email.blank?
        @err_string = @err_string + '\n' +"Please enter shipping phone" 
      end  
    end 
    
    if @err_string.blank? && session[:cart_obj].size>0 
      unless params[:billing][:email].blank?
        @orderer = Customer.where(:email=>params[:billing][:email]).first 
        
        if @orderer

          @orderer.billing_first_name = shipping_first_name
          @orderer.billing_last_name = shipping_last_name
          @orderer.billing_address1 = shipping_address1
          @orderer.billing_address2 = shipping_address2
          @orderer.billing_city = shipping_city
          @orderer.billing_state = shipping_state
          @orderer.billing_country = shipping_country
          @orderer.billing_zip = shipping_zip
          @orderer.shipping_phone = shipping_phone
              
          if params[:same_shipping].to_s == "1" 
            @orderer.first_name = shipping_first_name
            @orderer.last_name = shipping_last_name
            @orderer.address1 = shipping_address1
            @orderer.address2 = shipping_address2
            @orderer.city = shipping_city
            @orderer.state = shipping_state
            @orderer.country = shipping_country
            @orderer.zip = shipping_zip
            @orderer.phone = shipping_phone 
          else
            @orderer.first_name = first_name
            @orderer.last_name = last_name
            @orderer.email = email
            @orderer.address1 = address
            @orderer.address2 = address2
            @orderer.city = city
            @orderer.state = state
            @orderer.country = country
            @orderer.zip = zip
            @orderer.phone = phone              
          end 
          
          if @orderer.valid?
            @orderer.save
          else
            @error = @orderer.errors
          end 
        else 
          @orderer = Customer.new            

          @orderer.billing_first_name = shipping_first_name
          @orderer.billing_last_name = shipping_last_name
          @orderer.billing_address1 = shipping_address1
          @orderer.billing_address2 = shipping_address2
          @orderer.billing_city = shipping_city
          @orderer.billing_state = shipping_state
          @orderer.billing_country = shipping_country
          @orderer.billing_zip = shipping_zip
          @orderer.shipping_phone = shipping_phone          
          
          if params[:same_shipping].to_s == "1" 
            @orderer.first_name = shipping_first_name
            @orderer.last_name = shipping_last_name
            @orderer.address1 = shipping_address1
            @orderer.address2 = shipping_address2
            @orderer.city = shipping_city
            @orderer.state = shipping_state
            @orderer.country = shipping_country
            @orderer.zip = shipping_zip
            @orderer.phone = shipping_phone 
            @orderer.email = email
          else
            @orderer.first_name = first_name
            @orderer.last_name = last_name
            @orderer.email = email
            @orderer.address1 = address
            @orderer.address2 = address2
            @orderer.city = city
            @orderer.state = state
            @orderer.country = country
            @orderer.zip = zip
            @orderer.phone = phone              
          end 
                
          if @orderer.valid?
            @orderer.save
          else 
            @errors = @orderer.errors.full_messages 
            @errors.each do |p| 
              @err_string = @err_string + p.to_s + "," 
            end  
          end
        end
        
        logger.info "..................."
        
        logger.info email.inspect
        
        if params[:payment_method] == "card"
          @processed = false
          @credit_card = CreditCard.new(:name=>params[:card_holder_name], :number=>params[:card_number], :cvc=>params[:card_cvv],:exp_month=>params[:CardExpirationMonth],:exp_year=>params[:CardExpirationYear])
          
          unless @credit_card.valid?  
            @errors = @credit_card.errors.messages 
            @errors.each do |p|  
              @err_string = @err_string + p[1][0] + "," 
            end  
          end   
           
          if (@errors.nil? || @errors.empty? || @errors == "") && @credit_card.valid?    
            begin 
              if @orderer.stripe_id.blank? 
                stripe_customer = Stripe::Customer.create(email: @orderer.email) 
                @orderer.stripe_id = stripe_customer.id
                @orderer.save
              end   
              total_price = 0 
              product = nil 
              
              qty = 0
              if session[:cart_obj] 
                session[:cart_obj] .each do |obj| 
                   total_price += obj[:price].to_f 
                   qty += obj[:quantity].to_f 
                end 
              end              
              if session[:discount] && session[:discount].to_f > 0
                total_price = total_price - session[:discount].to_f
              end
              total_price = total_price*100 + shipping_amount*100  
              
              if total_price > 0  
                @order = Order.new(:shipping_code=>shipping_carrier, :version_2_order=>true, :orderer_id=>@orderer.id, :orderer_type=>"Customer", :order_type=>"normal", :paid=>false, :payment_type=>"card")          
                if session[:discount] && session[:discount].to_f > 0
                  @order.discount = session[:discount].to_f
                  @order.coupon_code = session[:discount_code]
                end
                charge = Stripe::Charge.create(
                   #customer: @orderer.stripe_id,
                  amount: total_price.to_i,
                  description: "normal order",
                  currency: 'usd',
                  card: { name: params[:card_holder_name], number:params[:card_number], cvc:params[:card_cvv], exp_month:params[:CardExpirationMonth], exp_year:params[:CardExpirationYear]}
                ) 
                @order.stripe_id = charge.id 
                @orderer.save!
                @order.host = request.host  
                @order.paid = true
                @order.save     

                if total_price > 18000
                  @order.held = true
                  @order.save
                end
                
                session[:cart_obj].each do |obj|    
                  
                  logger.info "................................."
                  logger.info obj.inspect
                  logger.info "................................."
                  
                  if ["Spray, Water resistant, Optimizer-Jet Black 38g Fibre", "Spray, Water resistant, Optimizer-Black 38g Fibre", "Spray, Water resistant, Optimizer-Brown 38g Fibre", "Spray, Water resistant, Optimizer-Dark Brown 38g Fibre", "Spray, Water resistant, Optimizer-Light Brown 38g Fibre", "Spray, Water resistant, Optimizer-Auburn 38g Fibre", "Spray, Water resistant, Optimizer-Light Blonde 38g Fibre","Spray, Water resistant, Optimizer-Blonde 38g Fibre"].include?( obj[:name].to_s )            
                    product1 = Product.where(:description=>"Optimizer",:product_type=>'normal').first 
                    if product1  
                      @order.order_items.create(:product_id=>product1.id, :price=>0,:product_type=>"normal", :quantity=>obj[:quantity].to_i)
                    end               
                    product2 = Product.where(:description=>"Hair Illusion Fiber Hold Spray",:product_type=>'normal').first 
                    if product2  
                      @order.order_items.create(:product_id=>product2.id, :price=>0,:product_type=>"normal", :quantity=>obj[:quantity].to_i)
                    end 
                    
                    product3 = Product.where(:description=>"Water Resistant Spray",:product_type=>'normal').first  
                    if product3  
                      @order.order_items.create(:product_id=>product3.id, :price=>0,:product_type=>"normal", :quantity=>obj[:quantity].to_i)
                    end 
                               
                    product4 = Product.where(:description=>obj[:color],:product_type=>'normal').first 
                    if product4  
                      @order.order_items.create(:product_id=>product4.id, :price=>@price_swof.to_f*100,:product_type=>"normal", :quantity=>obj[:quantity].to_i)
                    end
                    @order.save(:validate=>false)
                  elsif obj[:name] == "Spray, Water resistant, Optimizer"
                    
                    product1 = Product.where(:description=>"Optimizer",:product_type=>'normal').first 
                    
                    if product1  
                      @order.order_items.create(:product_id=>product1.id, :price=>0,:product_type=>"normal", :quantity=>obj[:quantity].to_i)
                    end                           
                    product2 = Product.where(:description=>"Hair Illusion Fiber Hold Spray",:product_type=>'normal').first 
                    if product2  
                      @order.order_items.create(:product_id=>product2.id, :price=>0,:product_type=>"normal", :quantity=>obj[:quantity].to_i)
                    end 
                    
                    product3 = Product.where(:description=>"Water Resistant Spray",:product_type=>'normal').first  
                    if product3  
                      @order.order_items.create(:product_id=>product3.id, :price=>@price_swo.to_f*100,:product_type=>"normal", :quantity=>obj[:quantity].to_i)
                    end 
                    @order.save(:validate=>false)
                  elsif ["Value Pack 2-Light Blonde", "Value Pack 2-Blonde", "Value Pack 2-Black", "Value Pack 2-Jet Black", "Value Pack 2-Dark Brown","Value Pack 2-Brown", "Value Pack 2-Light Brown","Value Pack 2-Auburn"].include?( obj[:name].to_s) 
        
                    product1 = Product.where(:description=>obj[:color], :product_type=>"normal").first   
                    if product1  
                      @order.order_items.create(:product_id=>product1.id, :price=>(@price_2x/2).to_f*100,:product_type=>"normal", :quantity=>2)
                    end 
                  elsif ["Value Pack 3-Light Blonde", "Value Pack 3-Blonde", "Value Pack 3-Black", "Value Pack 3-Jet Black", "Value Pack 3-Dark Brown","Value Pack 3-Brown", "Value Pack 3-Light Brown","Value Pack 3-Auburn"].include?( obj[:name].to_s) 
      
                    product1 = Product.where(:description=>obj[:color], :product_type=>"normal").first  
                    if product1 
                      @order.order_items.create(:product_id=>product1.id, :price=>(@price_3x/3).to_f*100,:product_type=>"normal", :quantity=>3)
                    end 
                    
                  elsif ["Value Pack 4-Light Blonde", "Value Pack 4-Blonde", "Value Pack 4-Black", "Value Pack 4-Jet Black", "Value Pack 4-Dark Brown","Value Pack 4-Brown", "Value Pack 4-Light Brown","Value Pack 4-Auburn"].include?( obj[:name].to_s) 
                    logger.info "XXXXXXXXXXXXXXXXXXXXX"
                    product1 = Product.where(:description=>obj[:color], :product_type=>"normal").first  
                    if product1 
                      @order.order_items.create(:product_id=>product1.id, :price=>(@price_4x/4).to_f*100,:product_type=>"normal", :quantity=>4)
                    end
                  elsif ["Value Pack 5-Light Blonde", "Value Pack 5-Blonde", "Value Pack 5-Black", "Value Pack 5-Jet Black", "Value Pack 5-Dark Brown","Value Pack 5-Brown", "Value Pack 5-Light Brown","Value Pack 5-Auburn"].include?( obj[:name].to_s) 
          
                    product1 = Product.where(:description=>obj[:color], :product_type=>"normal").first  
                    if product1 
                      @order.order_items.create(:product_id=>product1.id, :price=>(@price_5x/5).to_f*100,:product_type=>"normal", :quantity=>5)
                    end
                  elsif ["Combo Pack-Blonde","Combo Pack-Black","Combo Pack-Brown","Combo Pack-Dark Brown","Combo Pack-Auburn","Combo Pack-Light Blonde","Combo Pack-Jet Black","Combo Pack-Light Brown"].include?( obj[:name].to_s )      
                    
                    product1 = Product.where(:description=>obj[:color], :product_type=>"normal").first  
                    if product1 
                      @order.order_items.create(:product_id=>product1.id, :price=>@price_combo.to_f*100,:product_type=>"normal", :quantity=>1)
                      spry = Product.where(:description=>"Hair Illusion Fiber Hold Spray").first   
                      @order.order_items.create(:product_id=>spry.id, :price=>0,:product_type=>"normal", :quantity=>1)
                      opt = Product.where(:description=>"Optimizer").first   
                      @order.order_items.create(:product_id=>opt.id, :price=>0,:product_type=>"normal", :quantity=>1)
                    end  
                  elsif ["Value Pack 6-Jet Black","Value Pack 6-Black","Value Pack 6-Dark Brown","Value Pack 6-Brown","Value Pack 6-Light Brown","Value Pack 6-Auburn","Value Pack 6-Blonde","Value Pack 6-Light Blonde"].include?( obj[:name].to_s )
                    
                    product1 = Product.where(:description=>"Spray Applicator",:product_type=>'normal').first 
                    if product1  
                      @order.order_items.create(:product_id=>product1.id, :price=>(@price_saf)*100,:product_type=>"normal", :quantity=>obj[:quantity].to_i)
                    end
                    
                    product2 = Product.where(:description=>"Hair Illusion Fiber Hold Spray",:product_type=>'normal').first 
                    if product2  
                      @order.order_items.create(:product_id=>product2.id, :price=>0,:product_type=>"normal", :quantity=>obj[:quantity].to_i)
                    end
                    
                    color = obj[:name].split("-")
                    
                    product3 = Product.where(:description=>color[1],:product_type=>'normal').first 
                    if product3  
                      @order.order_items.create(:product_id=>product3.id, :price=>0,:product_type=>"normal", :quantity=>obj[:quantity].to_i)
                    end 
                  else
                    product = Product.where(:description=>obj[:name]).first
                    if product
                      @order.order_items.create(:product_id=>product.id, :price=>obj[:unit_price].to_f*100,:product_type=>"normal", :quantity=>obj[:quantity].to_i)
                    end
                  end
                end
  
                card = CustomerCard.where("customer_id=?",@orderer.id).first
                unless card
                  card = CustomerCard.new(:card_name=>params[:card_holder_name], :card_number=>params[:card_number], :ccv=>params[:card_cvv], :exp_month=>params[:CardExpirationMonth], :exp_year=>params[:CardExpirationYear], :customer_id=>@orderer.id)
                  card.save     
                else 
                  card.update_attributes({card_name: params[:card_holder_name], card_number: params[:card_number], ccv:params[:card_cvv], exp_month:params[:CardExpirationMonth], exp_year:params[:CardExpirationYear]})
                end  
                @order.update_attribute(:process_handling_price, 0)
                @order.update_attribute(:ship_from_shipwire, !@order.can_ship_from_amazon) 
                @order.update_attribute(:shipping_price, shipping_amount.to_f)
                #send email
                OrderMailer.order_receipt(@order.id).deliver
                OrderMailer.admin_notification(@order.id).deliver
                session[:cart_obj] = nil
                session[:country_shipping_code] = nil
                session[:shipping_price] = nil
                
              end 
            rescue Stripe::CardError => e 
              # Since it's a decline, Stripe::CardError will be caught
              body = e.json_body
              err  = body[:error]
              @error = err
              @order.paid = false if @order
              @order.cancelled = true if @order
              @order.save if @order
              card.destroy if card
              puts "Status is: #{e.http_status}"
              puts "Type is: #{err[:type]}"
              puts "Code is: #{err[:code]}"
              # param is '' in this case
              puts "Param is: #{err[:param]}"
              puts "Message is: #{err[:message]}" 
              flash[:alert] = err[:message] 
              @err_string = err[:message] 
            end  
          else
            card.destroy if card
          end   
        else  
          #inside paypal section
          total_price = 0 
          product = nil  
          qty = 0
          if session[:cart_obj] 
            session[:cart_obj] .each do |obj| 
              total_price += obj[:price].to_f 
              qty += obj[:quantity].to_f 
            end 
          end               
          total_price = total_price + shipping_amount  
              
          if total_price > 0  
            @order = Order.new(:shipping_code=>shipping_carrier, :version_2_order=>true, :orderer_id=>@orderer.id, :orderer_type=>"Customer", :order_type=>"normal", :paid=>false, :payment_type=>"paypal", :paid=>false)          
            
            if session[:discount] && session[:discount].to_f > 0
              @order.discount = session[:discount].to_f
              @order.coupon_code = session[:discount_code]
            end
                
            @orderer.save!
            @order.host = request.host  
            @order.save     

            if total_price > 180
              @order.held = true
              @order.save
            end
            
            logger.info session[:cart_obj].inspect
            logger.info "....................."
            session[:cart_obj] .each do |obj|  

                  if ["Spray, Water resistant, Optimizer-Jet Black 38g Fibre", "Spray, Water resistant, Optimizer-Black 38g Fibre", "Spray, Water resistant, Optimizer-Brown 38g Fibre", "Spray, Water resistant, Optimizer-Dark Brown 38g Fibre", "Spray, Water resistant, Optimizer-Light Brown 38g Fibre", "Spray, Water resistant, Optimizer-Auburn 38g Fibre", "Spray, Water resistant, Optimizer-Light Blonde 38g Fibre","Spray, Water resistant, Optimizer-Blonde 38g Fibre"].include?( obj[:name].to_s )            
                    product1 = Product.where(:description=>"Optimizer",:product_type=>'normal').first 
                    if product1  
                      @order.order_items.create(:product_id=>product1.id, :price=>0,:product_type=>"normal", :quantity=>obj[:quantity].to_i)
                    end                           
                    product2 = Product.where(:description=>"Hair Illusion Fiber Hold Spray",:product_type=>'normal').first 
                    if product2  
                      @order.order_items.create(:product_id=>product2.id, :price=>0,:product_type=>"normal", :quantity=>obj[:quantity].to_i)
                    end 
                    
                    product3 = Product.where(:description=>"Water Resistant Spray",:product_type=>'normal').first  
                    if product3  
                      @order.order_items.create(:product_id=>product3.id, :price=>0,:product_type=>"normal", :quantity=>obj[:quantity].to_i)
                    end 
                               
                    product4 = Product.where(:description=>obj[:color],:product_type=>'normal').first 
                    if product4  
                      @order.order_items.create(:product_id=>product4.id, :price=>@price_swof.to_f*100,:product_type=>"normal", :quantity=>obj[:quantity].to_i)
                    end
                    @order.save(:validate=>false)
                  elsif obj[:name] == "Spray, Water resistant, Optimizer"
                    
                    logger.info obj.inspect
                    
                    product1 = Product.where(:description=>"Optimizer",:product_type=>'normal').first 
                    
                    if product1  
                      @order.order_items.create(:product_id=>product1.id, :price=>0,:product_type=>"normal", :quantity=>obj[:quantity].to_i)
                    end                           
                    product2 = Product.where(:description=>"Hair Illusion Fiber Hold Spray",:product_type=>'normal').first 
                    if product2  
                      @order.order_items.create(:product_id=>product2.id, :price=>0,:product_type=>"normal", :quantity=>obj[:quantity].to_i)
                    end 
                    
                    product3 = Product.where(:description=>"Water Resistant Spray",:product_type=>'normal').first  
                    if product3  
                      @order.order_items.create(:product_id=>product3.id, :price=>@price_swo.to_f*100,:product_type=>"normal", :quantity=>obj[:quantity].to_i)
                    end 
                    @order.save(:validate=>false)

                 elsif ["Value Pack 2-Light Blonde", "Value Pack 2-Blonde", "Value Pack 2-Black", "Value Pack 2-Jet Black", "Value Pack 2-Dark Brown","Value Pack 2-Brown", "Value Pack 2-Light Brown","Value Pack 2-Auburn"].include?( obj[:name].to_s) 

                product1 = Product.where(:description=>obj[:color], :product_type=>"normal").first   
                if product1  
                  @order.order_items.create(:product_id=>product1.id, :price=>(@price_2x/2).to_f*100,:product_type=>"normal", :quantity=>2)
                end 
              elsif ["Value Pack 3-Light Blonde", "Value Pack 3-Blonde", "Value Pack 3-Black", "Value Pack 3-Jet Black", "Value Pack 3-Dark Brown","Value Pack 3-Brown", "Value Pack 3-Light Brown","Value Pack 3-Auburn"].include?( obj[:name].to_s) 

                product1 = Product.where(:description=>obj[:color], :product_type=>"normal").first  
                if product1 
                  @order.order_items.create(:product_id=>product1.id, :price=>(@price_3x/3).to_f*100,:product_type=>"normal", :quantity=>3)
                end 
              elsif ["Value Pack 4-Light Blonde", "Value Pack 4-Blonde", "Value Pack 4-Black", "Value Pack 4-Jet Black", "Value Pack 4-Dark Brown","Value Pack 4-Brown", "Value Pack 4-Light Brown","Value Pack 4-Auburn"].include?( obj[:name].to_s) 
                product1 = Product.where(:description=>obj[:color], :product_type=>"normal").first  
                if product1 
                  @order.order_items.create(:product_id=>product1.id, :price=>(@price_4x/4).to_f*100,:product_type=>"normal", :quantity=>4)
                end
              elsif ["Value Pack 5-Light Blonde", "Value Pack 5-Blonde", "Value Pack 5-Black", "Value Pack 5-Jet Black", "Value Pack 5-Dark Brown","Value Pack 5-Brown", "Value Pack 5-Light Brown","Value Pack 5-Auburn"].include?( obj[:name].to_s) 

                product1 = Product.where(:description=>obj[:color], :product_type=>"normal").first  
                if product1 
                  @order.order_items.create(:product_id=>product1.id, :price=>(@price_5x/5).to_f*100,:product_type=>"normal", :quantity=>5)
                end
                  elsif ["Combo Pack-Blonde","Combo Pack-Black","Combo Pack-Brown","Combo Pack-Dark Brown","Combo Pack-Auburn","Combo Pack-Light Blonde","Combo Pack-Jet Black","Combo Pack-Light Brown"].include?( obj[:name].to_s )      
                    
                    product1 = Product.where(:description=>obj[:color], :product_type=>"normal").first  
                    if product1 
                      @order.order_items.create(:product_id=>product1.id, :price=>@price_combo.to_f*100,:product_type=>"normal", :quantity=>1)
                      spry = Product.where(:description=>"Hair Illusion Fiber Hold Spray").first   
                      @order.order_items.create(:product_id=>spry.id, :price=>0,:product_type=>"normal", :quantity=>1)
                      opt = Product.where(:description=>"Optimizer").first   
                      @order.order_items.create(:product_id=>opt.id, :price=>0,:product_type=>"normal", :quantity=>1)
                    end  
                  elsif ["Value Pack 6-Jet Black","Value Pack 6-Black","Value Pack 6-Dark Brown","Value Pack 6-Brown","Value Pack 6-Light Brown","Value Pack 6-Auburn","Value Pack 6-Blonde","Value Pack 6-Light Blonde"].include?( obj[:name].to_s )
                    
                    product1 = Product.where(:description=>"Spray Applicator",:product_type=>'normal').first 
                    if product1  
                      @order.order_items.create(:product_id=>product1.id, :price=>(@price_saf)*100,:product_type=>"normal", :quantity=>obj[:quantity].to_i)
                    end
                    
                    product2 = Product.where(:description=>"Hair Illusion Fiber Hold Spray",:product_type=>'normal').first 
                    if product2  
                      @order.order_items.create(:product_id=>product2.id, :price=>0,:product_type=>"normal", :quantity=>obj[:quantity].to_i)
                    end
                    
                    color = obj[:name].split("-")
                    
                    product3 = Product.where(:description=>color[1],:product_type=>'normal').first 
                    if product3  
                      @order.order_items.create(:product_id=>product3.id, :price=>0,:product_type=>"normal", :quantity=>obj[:quantity].to_i)
                    end 
              else
                product = Product.where(:description=>obj[:name]).first
                if product
                  @order.order_items.create(:product_id=>product.id, :price=>obj[:unit_price].to_f*100,:product_type=>"normal", :quantity=>obj[:quantity].to_i)
                end
              end 
            end  
            session[:orderer_id] = @order.id
            if session[:discount] && session[:discount].to_f > 0
              total_price = total_price - session[:discount].to_f
            end
            session[:total_price] = total_price.round(2)
            @order.update_attribute(:process_handling_price, 0)
            @order.update_attribute(:shipping_price, shipping_amount.to_f) 
            @order.update_attribute(:ship_from_shipwire, !@order.can_ship_from_amazon) 
             

          end 
        end
      end
    end    
  end
  
  def payment  
    @order = Order.find session[:orderer_id]
  end
  
  def after_payment_page   
    
    
  end
  
  def create_club_order 
    @order = nil
    @errors = []
    @err_string = "" 
    
    if params[:same_shipping].to_s == "0"
      @err_string = "Please enter shipping first name" if params[:billing][:shipping_firstname].blank?
      
      if params[:billing][:shipping_state].blank?
        @err_string = @err_string + '\n' +"Please enter billing state" 
      end
      
      if params[:billing][:shipping_lastname].blank?
        @err_string = @err_string + '\n' +"Please enter shipping last name" 
      end 
      
      if params[:billing][:shipping_address].blank?
        @err_string = @err_string + '\n' +"Please enter shipping address" 
      end
      
      if params[:billing][:shipping_city].blank?
        @err_string = @err_string + '\n' +"Please enter shipping city" 
      end
      
      if params[:billing][:shipping_state].blank?
        @err_string = @err_string + '\n' +"Please select shipping state" 
      end
      
      if params[:billing][:shipping_zip].blank?
        @err_string = @err_string + '\n' +"Please enter shipping zip" 
      end
      
      if params[:billing][:shipping_phone].blank?
        @err_string = @err_string + '\n' +"Please enter shipping phone" 
      end 
      
    end
    
    if @err_string.blank?  
      unless params[:color].blank?
        unless params[:billing][:email].blank?
          @orderer = Customer.where(:email=>params[:billing][:email]).first
          
          if @orderer
            @orderer.first_name = params[:billing][:firstname]
            @orderer.last_name = params[:billing][:lastname]
            @orderer.email = params[:billing][:email]
            @orderer.address1 = params[:billing][:address]
            @orderer.address2 = params[:billing][:address_2]
            @orderer.city = params[:billing][:city]
            @orderer.state = params[:billing][:state]
            @orderer.country = params[:billing][:country]
            @orderer.zip = params[:billing][:zip]
            @orderer.phone = params[:billing][:phone]
             
            if params[:same_shipping].to_s == "0"
              @orderer.billing_first_name = params[:billing][:shipping_firstname]
              @orderer.billing_last_name = params[:billing][:shipping_lastname] 
              @orderer.billing_address1 = params[:billing][:shipping_address]
              @orderer.billing_address2 = params[:billing][:shipping_address_2]
              @orderer.billing_city = params[:billing][:shipping_city]
              @orderer.billing_state = params[:billing][:shipping_state]
              @orderer.billing_country = params[:billing][:country]
              @orderer.billing_zip = params[:billing][:shipping_zip]
              @orderer.shipping_phone = params[:billing][:shipping_phone]
            else 
              @orderer.billing_first_name = params[:billing][:firstname]
              @orderer.billing_last_name = params[:billing][:lastname]
              @orderer.billing_address1 = params[:billing][:address]
              @orderer.billing_address2 = params[:billing][:address_2]
              @orderer.billing_city = params[:billing][:city]
              @orderer.billing_state = params[:billing][:state]
              @orderer.billing_country = params[:billing][:country]
              @orderer.billing_zip = params[:billing][:zip]
              @orderer.shipping_phone = params[:billing][:phone]
            end
            
            if @orderer.valid?
              @orderer.save
            else
              @error = @orderer.errors
            end 
          else 
            @orderer = Customer.new(:first_name=>params[:billing][:firstname],:last_name=>params[:billing][:lastname],:email=>params[:billing][:email], :address1=>params[:billing][:address],
            :address2=>params[:billing][:address_2],:city=>params[:billing][:city], :phone=>params[:billing][:phone], :state=>params[:billing][:state], :country=>params[:billing][:country], :zip=>params[:billing][:zip])
            
            if params[:same_shipping].to_s == "0"
              @orderer.billing_first_name = params[:billing][:shipping_firstname]
              @orderer.billing_last_name = params[:billing][:shipping_lastname] 
              @orderer.billing_address1 = params[:billing][:shipping_address]
              @orderer.billing_address2 = params[:billing][:shipping_address_2]
              @orderer.billing_city = params[:billing][:shipping_city]
              @orderer.billing_state = params[:billing][:shipping_state]
              @orderer.billing_country = params[:billing][:shipping_country]
              @orderer.billing_zip = params[:billing][:shipping_zip]
              @orderer.shipping_phone = params[:billing][:shipping_phone]
            else 
              @orderer.billing_first_name = params[:billing][:firstname]
              @orderer.billing_last_name = params[:billing][:lastname]
              @orderer.billing_address1 = params[:billing][:address]
              @orderer.billing_address2 = params[:billing][:address_2]
              @orderer.billing_city = params[:billing][:city]
              @orderer.billing_state = params[:billing][:state]
              @orderer.billing_country = params[:billing][:country]
              @orderer.billing_zip = params[:billing][:zip]
              @orderer.shipping_phone = params[:billing][:phone]
            end
                
            if @orderer.valid?
              @orderer.save
            else 
              @errors = @orderer.errors.full_messages 
              @errors.each do |p| 
                @err_string = @err_string + p.to_s + "," 
              end  
            end
          end
        end
        @processed = false
        @credit_card = CreditCard.new(:name=>params[:card_holder_name], :number=>params[:card_number], :cvc=>params[:card_cvv],:exp_month=>params[:CardExpirationMonth],:exp_year=>params[:CardExpirationYear])
        
        unless @credit_card.valid?  
          @errors = @credit_card.errors.messages 
          @errors.each do |p|  
            @err_string = @err_string + p[1][0] + "," 
          end  
        end   
         
        if (@errors.nil? || @errors.empty? || @errors == "") && @credit_card.valid?    
          begin 
            if @orderer.stripe_id.blank? 
              stripe_customer = Stripe::Customer.create(email: @orderer.email) 
              @orderer.stripe_id = stripe_customer.id
              @orderer.save
            end   
            total_price = 8.95
            product = nil             
            if total_price > 0  
              @order = Order.new(:version_2_order=>true, :orderer_id=>@orderer.id, :orderer_type=>"Customer", :order_type=>"recurrent", :paid=>false, :payment_type=>"card")          
   
              #set price to stripe
              total_price = total_price*100
              charge = Stripe::Charge.create(
                 #customer: @orderer.stripe_id,
                amount: total_price.to_i,
                description: "recurrent first order",
                currency: 'usd',
                card: { name: params[:card_holder_name], number:params[:card_number], cvc:params[:card_cvv], exp_month:params[:CardExpirationMonth], exp_year:params[:CardExpirationYear]}
              ) 
              @order.stripe_id = charge.id 
              @orderer.save!
              @order.host = request.host  
              @order.paid = true
              @order.first_delivery_date = Date.today
              @order.next_delivery_date = Date.today 
              @order.save      
 
                product = Product.where(:description=>params[:color], :product_type=>"recurrent").first 
                if product
                  @order.order_items.create(:product_id=>product.id, :tax=>895, :price=>0,:product_type=>"recurrent", :quantity=>1) 
                  upsell = Product.where(:description=>"Optimizer").first
                  @order.order_items.create(:product_id=>upsell.id, :price=>0,:product_type=>"recurrent", :quantity=>1) 
                end 
 
              
              card = CustomerCard.where("customer_id=?",@orderer.id).first
              unless card
                card = CustomerCard.new(:card_name=>params[:card_holder_name], :card_number=>params[:card_number], :ccv=>params[:card_cvv], :exp_month=>params[:CardExpirationMonth], :exp_year=>params[:CardExpirationYear], :customer_id=>@orderer.id)
                card.save     
              else 
                card.update_attributes({card_name: params[:card_holder_name], card_number: params[:card_number], ccv:params[:card_cvv], exp_month:params[:CardExpirationMonth], exp_year:params[:CardExpirationYear]})
              end 
                 
                @order.update_attribute(:process_handling_price, 8.95)
                @order.update_attribute(:shipping_price, 0) 
                @order.update_attribute(:ship_from_shipwire, !@order.can_ship_from_amazon) 
                
                logger.info "CCCCCCCCCCCCCCCC"
                logger.info @order.can_ship_from_amazon.inspect
                
                #send email
                OrderMailer.order_receipt(@order.id).deliver
                OrderMailer.admin_notification(@order.id).deliver  
            end
            
          rescue Stripe::CardError => e 
            # Since it's a decline, Stripe::CardError will be caught
            body = e.json_body
            err  = body[:error]
            @error = err
            @order.paid = false if @order
            @order.cancelled = true if @order
            @order.save if @order
            card.destroy if card
            puts "Status is: #{e.http_status}"
            puts "Type is: #{err[:type]}"
            puts "Code is: #{err[:code]}"
            # param is '' in this case
            puts "Param is: #{err[:param]}"
            puts "Message is: #{err[:message]}" 
            flash[:alert] = err[:message] 
            @err_string = err[:message] 
            end 
          end  
        else
          card.destroy if card
        end   
     end         
  end
  
  def faq
  end

  def photos
  end

  def what_is_it
  end

  def how_it_works
  end

  def about_us
  end

  def color
  end

  def contact_us
  end

  def mens_hair_loss
  end

  def womens_hair_loss
  end

  def thankyou 
  end

  def forgot_password_email
    @errors = ""
    if params[:email] == ""
      @errors = "Please enter your valid Wholesaler email id"
    else
      if params[:from] == "user"
        customer = Customer.where(:email=>params[:email]).first  
        if customer
          OrderMailer.customer_reset_email(customer.id).deliver! 
        else
          @errors = "Please enter your valid email id"
        end
      else
        distributor = Distributor.where(:email=>params[:email]).first 
        if distributor
          OrderMailer.reset_email(distributor.id).deliver! 
        else
          @errors = "Please enter your valid Wholesaler email id"
        end
      end 
    end
  end
  
  def password_reset_success
    
  end
    
  def buy_now
    session[:cart] = nil
  end
  
  def after_payment
    session[:orderer_id] = nil
    session[:total_price] = nil
    session[:cart_obj] = nil 
            
  #  if params[:payer_status] == "verified"
      order = Order.find params[:item_number].to_i
      
      if order 
        order.paid = true         
        order.save 
        
        order.first_delivery_date = Date.today
        order.next_delivery_date = Date.today 
        customer = Customer.find order.orderer_id
        customer.paypal = params[:payer_email]
        customer.save
        
        OrderMailer.order_receipt(order.id).deliver!  
        OrderMailer.admin_notification(order.id).deliver! 
      end
   # else
    #  order = Order.find params[:item_number] 
    #  order.cancelled = true
   ##   order.save
   # end      
  end
  
  def forum 
    @forums = Forum.where(:approved=>true, :domain_name=>"hairillusion.com")#.paginate(per_page: 2, page: params[:page])  
  end
  
  def get_forums
    @forums = []
    if params[:search][:country].blank? && params[:order][:state].blank? 
      @forums = []#.paginate(per_page: 2, page: params[:page])
    elsif params[:search][:country].blank?
      @forums = Forum.where(:domain_name=>"hairillusion.net",:approved=>true, :state=>params[:order][:state])#.paginate(per_page: 2, page: params[:page])
    elsif params[:order][:state].blank?  
      @forums = Forum.where(:domain_name=>"hairillusion.net",:approved=>true, :country=>params[:search][:country]).paginate(per_page: 2, page: params[:page])#.paginate(per_page: 2, page: params[:page])
    else
      @forums = Forum.where(:domain_name=>"hairillusion.net",:approved=>true, :country=>params[:search][:country], :state=>params[:order][:state])#.paginate(per_page: 2, page: params[:page])
    end
  end
  
  def new_forum
    @forum = Forum.new
  end
  
  def save_forum
    @forum = Forum.new(admin_forum_params)
    @forum.state = params[:order][:state]
    @forum.domain_name = "hairillusion.net"
    if @forum.save 
      @forum.update_attribute(:approved,false) 
     # OrderMailer.send_forum_email(@forum.content).deliver!
      @forums = Forum.where(:approved=>true) 
      redirect_to forum_path, notice: 'Your forum request is successfully submitted.'
    else 
      render action: 'new_forum'
    end 
  end
  
  def get_states  
  end
  
  def auto_ship
    @orders = nil
    if @customer
      @orders = @customer.orders.where(:order_type=>"recurrent", :cancelled=>false)
    end
  end
  
  def account_details
    
  end
  
  def past_orders
    @orders = Array.new
    if @customer
      @orders = @customer.orders.where(:cancelled=>false, :order_type=>"normal", :parent_order_id=>nil, :paid=>true).order("created_at desc")
    end
  end
 
 
 private  
  def admin_forum_params
    params.require(:forum).permit(:subject, :content, :approved, :country, :state, :address, :name)
  end  
  
  def check_logged_in
    @customer = nil
    if session[:customer_id]
      @customer = Customer.find session[:customer_id]
    end
  end
  
  def resolve_layout
    case action_name
    when "dashboard","account_details", "auto_ship", "past_orders", "edit_address", "edit_card", "edit_color"
      if @customer 
        'dashboard'
      else 
        'application'
      end 
    else 
      "application"
    end
  end
  
  
  def setup_shipwire_carriers(items,address, qty)
          
    payload = {options: {  currency: "USD", groupBy: "all" }, order: { shipTo: address, items: items }} 
    
    logger.info payload.inspect
     
    Shipwire.configure do |config|
      config.username = "support@hairillusion.com"
      config.password = "ZZZack!!!"
      config.endpoint = URI::encode('https://api.shipwire.com')
    end 
    response = Shipwire::Rate.new.find(payload)  
         
    begin 
      if response.body['error_summary'].blank? 
        options = response.body['resource']['rates'][0]['serviceOptions'] rescue [] 
        @carriers = []
        options.each do |rate|
          obj = rate['shipments'][0]   
          amount = obj['cost']['amount'].to_f
          handling = 1.95 + (qty-1)*0.7
          amount = amount + handling 
          amount = sprintf('%.2f', amount) 
          
          carrier = [obj['carrier']['description'].downcase!]
          logger.info ".......--#{carrier}"
          if carrier.include? "usps first-class mail international"
           # @carriers << { shipping_code: obj['carrier']['code'], name: obj['carrier']['description'], deliver_min_date: obj['expectedDeliveryMinDate'].to_date+1.day,deliver_max_date: obj['expectedDeliveryMaxDate'].to_date+2.day, amount: amount, currency: obj['cost']['currency'] } 
          else
            @carriers << { shipping_code: obj['carrier']['code'], name: obj['carrier']['description'], deliver_min_date: obj['expectedDeliveryMinDate'].to_date+1.day,deliver_max_date: obj['expectedDeliveryMaxDate'].to_date+2.day, amount: amount, currency: obj['cost']['currency'] }     
          end

        end  
      else
        @error = response.body['error_summary']
      end  

    rescue
      @error = "Please enter valid address"
    end 
    
    logger.info @carriers.inspect
    
  end
  
  def setup_amazon_carriers(carriers)
    begin
    @carriers = []
    carriers.each do |carrier|  
      logger.info carrier.inspect
      logger.info ",,,,,,,,,,,,,,,"
      @carriers << { shipping_code: carrier["ShippingSpeedCategory"], name: carrier["ShippingSpeedCategory"], deliver_min_date: carrier['FulfillmentPreviewShipments']['member']['LatestArrivalDate'].to_date, deliver_max_date: carrier['FulfillmentPreviewShipments']['member']['LatestArrivalDate'].to_date+3.days, amount: get_amount_from_hash(carrier['EstimatedFees']['member']), currency: 'S' } 
    end   
    rescue
      @error = "Please make sure you have entered valid address"
    end
  end
  
  def get_amount_from_hash(arr)  
    amount = 0 
    arr.each do |s|
      amount += s['Amount']['Value'].to_f
    end 
    return amount
  end 
  
end
