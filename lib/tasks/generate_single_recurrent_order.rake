namespace :hair do 
  desc 'generate orders rake started'
  task :generate_single_recurrent_order => :environment do
     orders = Order.where("id =?", 3350)
     
     orders.each do |order|
       puts order.id
       
        @orderer = order.orderer
        
        @order = Order.new(:version_2_order=>true, :orderer_id=>@orderer.id, :orderer_type=>"Customer", :order_type=>"normal", :parent_order_id=>order.id)  
        @order.save
        
        @order.update_attribute(:process_handling_price, 0)
        @order.update_attribute(:shipping_price, 4.95)
              
        puts "new order id=#{@order.id}--email-#{@orderer.email}"
        order.order_items.each do |order_item|
          original_product = Product.find order_item.product_id
          new_product = Product.where(:description=>original_product.description, :product_type=>"normal").first 
          
          product_price = ProductPrice.first            
          if product_price
            price = product_price.recurrent_price*100
          else
            price = 2995
          end
                    
          if new_product.description == "Hair Illusion Fiber Hold Spray" || new_product.description == "Mirror" || new_product.description == "Optimizer"
            
          else
           OrderItem.create(:order_id=>@order.id,:product_id=>new_product.id, :price=>price, :tax=>495)           
          end  
        end       
        if @orderer.stripe_id.blank? 
            stripe_customer = Stripe::Customer.create(email: @orderer.email) 
            @orderer.stripe_id = stripe_customer.id
            @orderer.save 
          end    
          total_price = 0          
          @order.order_items.each do |o_i| 
            price = o_i.price 
            price += o_i.tax  if o_i.tax > 0 
            total_price = total_price + (price*o_i.quantity)  
            total_price = total_price + (o_i.quantity*100) if o_i.quantity>1 
          end  
      begin      
          customer_card = CustomerCard.find_by_customer_id @orderer.id
          if customer_card 
           charge = Stripe::Charge.create( 
              amount: total_price.to_i,
              description: order.id,
              currency: 'usd',
              card: { name: customer_card.card_name, number:customer_card.card_number, cvc:customer_card.ccv, 
              exp_month:customer_card.exp_month, exp_year:customer_card.exp_year}
            ) 
          end
          
        order.last_delivery_date = Date.today
        order.next_delivery_date = Date.today+ 1.month
        
        order.save
        OrderMailer.monthly_order_receipt(@order.id).deliver! 
        OrderMailer.monthly_order_notification(@order.id).deliver! 
      rescue Stripe::CardError => e  
        # Since it's a decline, Stripe::CardError will be caught
        body = e.json_body
        err  = body[:error]
        @order.cancelled = true 
        @order.save
        puts "Status is: #{e.http_status}"
        puts "Type is: #{err[:type]}"
        puts "Code is: #{err[:code]}"
        # param is '' in this case
        puts "Param is: #{err[:param]}"
        puts "Message is: #{err[:message]}"

        @errors = err[:message]
        OrderMailer.error_generated(@errors,order.id) 
      rescue => e
        # Something else happened, completely unrelated to Stripe
        @errors = e.message 
        @order.cancelled = true 
        @order.save
        OrderMailer.error_generated(@errors,@order.id)
      end 
     end
  end 
   
end
