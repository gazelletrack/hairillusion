   
namespace :hair do 
  desc 'generate orders rake started'
  task :generate_recurent_orders => :environment do
     Rails.logger.info "daily order created started..."
     orders = Order.where("parent_order_id is null and order_type ='recurrent' and next_delivery_date = ? and last_delivery_date < ? and cancelled=false and hc_order=false and card_error = false", Date.today, Date.today)
     Rails.logger.info "Total orders- #{orders.size}" if orders
     orders.each do |order|
       unless order.next_delivery_date.nil?
         Rails.logger.info order.id 
          @orderer = order.orderer 
          @order = Order.new(:version_2_order=>true, :orderer_id=>@orderer.id, :orderer_type=>"Customer", :order_type=>"normal", :parent_order_id=>order.id, :paid=>false)  
          @order.save
          
          @order.update_attribute(:process_handling_price, 0)
          @order.update_attribute(:shipping_price, 0)
                
          Rails.logger.info "new order id=#{@order.id}--email-#{@orderer.email}"
          order.order_items.each do |order_item|
            original_product = Product.find order_item.product_id
            new_product = Product.where(:description=>original_product.description, :product_type=>"normal").first 
            
            order_price = nil
            product_price = ProductPrice.first
            
            if @order.orderer.price.to_f > 0
              order_price = @order.orderer.price
            else 
              order_price = product_price.recurrent_price if product_price
            end

            if order_price && order_price > 0
              price = order_price*100
            else
              price = 2495
            end 
            
            shipping_price = 0
            if product_price
              #shipping_price = product_price.shipping_price*100
            end
            
            if new_product.description == "Hair Illusion Fiber Hold Spray" || new_product.description == "Mirror" || new_product.description == "Optimizer"
              
            else
             OrderItem.create(:order_id=>@order.id,:product_id=>new_product.id, :price=>price, :tax=>0)           
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
          #  total_price = 2495    
            customer_card = CustomerCard.find_by_customer_id @orderer.id
            if customer_card 
             charge = Stripe::Charge.create( 
                amount: total_price.to_i,
                description: order.id,
                currency: 'usd',
                card: { name: customer_card.card_name, number:customer_card.card_number, cvc:customer_card.ccv, 
                exp_month:customer_card.exp_month, exp_year:customer_card.exp_year}
              ) 
              if charge
                @order.paid = true
                @order.stripe_id = charge.id 
                @order.save
              end 
            end
          
          gap_days = order.gap_days.to_i
          order.last_delivery_date = Date.today
          if gap_days > 0
            order.next_delivery_date = Date.today+ gap_days.days
          else
            order.next_delivery_date = Date.today+ 1.months
          end 
          
          order.save
          OrderMailer.monthly_order_receipt(@order.id).deliver
          OrderMailer.monthly_order_notification(@order.id).deliver 
        rescue Stripe::CardError => e  
          # Since it's a decline, Stripe::CardError will be caught
          body = e.json_body
          err  = body[:error]
          @order.cancelled = true  
          @order.cancelled_at = Time.now
          @order.paid = false 
          @order.save
          if @order.parent_order_id
            order.card_error = true
            order.warning_sent = true
            order.save
            order = Order.find @order.parent_order_id
            begin
              order.orderer.send_login_details
            rescue
              next
            end 
          end 
          puts "Status is: #{e.http_status}"
          puts "Type is: #{err[:type]}"
          puts "Code is: #{err[:code]}"
          # param is '' in this case
          puts "Param is: #{err[:param]}"
          puts "Message is: #{err[:message]}"
          
          Rails.logger.info "Status is: #{e.http_status}"
          Rails.logger.info "Type is: #{err[:type]}"
          Rails.logger.info "Code is: #{err[:code]}"
          # param is '' in this case
          Rails.logger.info "Param is: #{err[:param]}"
          Rails.logger.info "Message is: #{err[:message]}"
  
          @errors = err[:message]
          OrderMailer.error_generated(@errors,order.id) 
        rescue => e
          # Something else happened, completely unrelated to Stripe
          @errors = e.message 
          @order.paid = false 
          @order.cancelled_at = Time.now
          @order.cancelled = true 
          @order.save
          OrderMailer.error_generated(@errors,@order.id)
        end   
      end     
     end
  end 
   
end
