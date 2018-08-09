class OrdersController < ApplicationController
  def new
    @orderer = Customer.new
    @order = @orderer.orders.build(order_items_attributes: [quantity: 1])
    @credit_card = CreditCard.new
  end

  def create
    
    if params[:get_shipping].to_s == "true"
      
      distributor = Distributor.find params[:order][:orderer_id]
      if distributor 
        items = []
        address = {}
        @error = ''
        qty = 0 
        
        first_name = distributor.first_name
        last_name = distributor.last_name 
        address = distributor.address1
        address2 = distributor.address2 
        country = distributor.country
        state = distributor.state
        city = distributor.city 
        zip = distributor.zip
      
        products = params[:order][:order_items_attributes]
        
        products.each_with_index do |obj,index|   
          d = obj[1]           
          if d[:quantity].to_i  > 0 
            qty +=d[:quantity].to_i 
            product = Product.find d[:product_id].to_i
            if product
              items << { :sku =>  product.sku, :quantity => d[:quantity], :commercialInvoiceValue => d[:price].to_f, :commercialInvoiceValueCurrency => 'USD'}
            end
          end
        end
      
        logger.info "......#{qty}........."
        logger.info items.inspect
        logger.info "......................"
        qty = qty.to_i
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
              :phone      => '', 
              :isCommercial    => 0, 
              :isPoBox    => 0
            } 
        end 
       
        logger.info address.inspect
       
        payload = {options: {  currency: "USD", groupBy: "all" }, order: { shipTo: address, items: items }} 
      
        Shipwire.configure do |config|
          config.username = "support@hairillusion.com"
          config.password = "ZZZack!!!"
          config.endpoint = URI::encode('https://api.shipwire.com')
        end 
      
        response = Shipwire::Rate.new.find(payload)   
        logger.info response.inspect
         logger.info qty
        begin 
          if response.body['error_summary'].blank? 
            options = response.body['resource']['rates'][0]['serviceOptions'] rescue [] 
            @carriers = []
            options.each do |rate|
             
              obj = rate['shipments'][0]   
              amount = obj['cost']['amount'].to_f
              
              handling = 1.95 + (qty-1)*1.95
              amount = amount + handling 
              amount = sprintf('%.2f', amount)
              @carriers << { shipping_code: obj['carrier']['code'], name: obj['carrier']['description'], deliver_min_date: obj['expectedDeliveryMinDate'].to_date+1.day,deliver_max_date: obj['expectedDeliveryMaxDate'].to_date+2.days, amount: amount, currency: obj['cost']['currency'] } 
            end  
            
            logger.info @carriers.inspect
          else
            @error = response.body['error_summary']
          end  
        rescue
         @error = "Please enter valid address, If address looks valid, retry to fetch carriers"
        end  
      else
        @error = "Please login as Wholesaler"
      end 
    else 
      @error = ""
      customer_order = false 
      if order_params[:orderer_id]
        @orderer = Distributor.find(order_params[:orderer_id])
        orderer_valid = true 
      end
  
      @order = Order.new(:shipping_code=>params[:shipment_name], :orderer_id=> order_params[:orderer_id], :orderer_type=>"Distributor", :host=>request.host, :hc_order=>false, :version_2_order=>false )
      
      total_qty = 0 
      total_price = 0 
      shipping_price = 0  
      params[:order][:order_items_attributes].each do |p|  
        if p[1][:quantity].to_i > 0
          total_qty += p[1][:quantity].to_i
          dpp = DistributorProductPrice.where("distributor_id=? and distributor_product_id=?", @orderer.id, p[1][:product_id].to_i).first            
          total_price = total_price + p[1][:quantity].to_i*dpp.price
        end
      end 
       
      if params[:shipment_price].present?
        shipping_price = params[:shipment_price].to_f
      else
        if total_qty > 0
          shipping_price = 5.95 + (total_qty-1)
        else
          shipping_price = 0
        end 
      end
      
      if @orderer.country && @orderer.country.downcase == "us"
        shipping_price = 25
      else
        shipping_price = 50        
      end
       
      total_price = total_price + shipping_price  
      total_price = (total_price*100).to_i
  
      @credit_card = CreditCard.new(cc_params)
  
      order_valid = @order.valid?
      credit_card_valid = @credit_card.valid?    
      
      if orderer_valid && order_valid && credit_card_valid && total_qty > 0   
        #begin
          stripe_customer = Stripe::Customer.create(card: cc_params, email: @orderer.email)  
          @orderer.stripe_id = stripe_customer.id  
          
          logger.info total_price.inspect 
        
          charge = Stripe::Charge.create(
            customer: @orderer.stripe_id,
            amount: total_price,
            description: "distributor order-id",
            currency: 'usd' 
          )  
          @order.shipping_price = shipping_price
          @order.stripe_id = charge.id 
          @order.save! 
          counter = 0 
          params[:order][:order_items_attributes].each_with_index do |p,index|  
            if p[1][:quantity].to_i > 0
              dpp = DistributorProductPrice.where("distributor_id=? and distributor_product_id=?", @orderer.id, p[1][:product_id].to_i).first
              if dpp 
                counter = counter + 1
                if counter == 1
                  @order.order_items.create(:order_id=>@order.id, :product_id=>p[1][:product_id].to_i, :product_type=>"DistributorProduct", :quantity=>p[1][:quantity].to_i, :price=>dpp.price*100,:s_h_cost=>595)                  
                else
                  order_item = OrderItem.new(:order_id=>@order.id, :product_id=>p[1][:product_id].to_i, :product_type=>"DistributorProduct", :quantity=>p[1][:quantity].to_i, :price=>dpp.price*100,:s_h_cost=>100)
                  order_item.save!           
                end  
                
              end
            end
          end  
          
          OrderMailer.receipt(@order, total_price, shipping_price*100).deliver!
          OrderMailer.send_notification(@order, total_price, shipping_price*100).deliver!   
            
       # rescue Stripe::CardError => e   
       #   @error = e.message
      #  rescue => e
         # Something else happened, completely unrelated to Stripe
       #  @error = e.message      
       # end 
      else    
        unless @credit_card.valid?      
          @credit_card.errors.messages.each do |p,s|     
            @error = "" if @error.nil? 
            @error = @error + s[1] + '\n' if s[1]
            @error = @error + s[0] + '\n' if s[0].include?("Please enter valid cvc")
          end  
          if ["Number Please enter valid card number"].include? @credit_card.errors.full_messages[0]
            @error = @error + "Number Please enter valid card number" + '\n'
          end
        end    
      end   
    end
  end
  

  
  def buy_product 
  end
  
  def confirmation
  end

  private
  def customer_params
    params.require(:customer).permit(:first_name, :last_name, :email, :address1, :address2, :city, :state, :zip, :country)
  end

  def order_params
    params.require(:order).permit(:orderer_id, order_items_attributes: [:product_id, :quantity])
  end

  def cc_params
    params.require(:credit_card).permit(:name, :number, :cvc, :exp_month, :exp_year)
  end
end
