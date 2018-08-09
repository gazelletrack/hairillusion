   
namespace :hair do 
  desc 'generate orders rake started'
  task :charge_customer => :environment do
     Rails.logger.info "daily order created started..."
     orders = Order.where("id=7221")
     Rails.logger.info "Total orders- #{orders.size}" if orders
     orders.each do |order| 
         Rails.logger.info order.id 
          @orderer = order.orderer  
          puts "email-#{@orderer.email}"
      
          if @orderer.stripe_id.blank? 
              stripe_customer = Stripe::Customer.create(email: @orderer.email) 
              @orderer.stripe_id = stripe_customer.id
              @orderer.save 
            end    
            total_price = 3490     
        begin              
            customer_card = CustomerCard.find_by_customer_id @orderer.id
            if customer_card 
             charge = Stripe::Charge.create( 
                amount: total_price.to_i,
                description: "Charge for aug 15th shipment",
                currency: 'usd',
                card: { name: customer_card.card_name, number:customer_card.card_number, cvc:customer_card.ccv, 
                exp_month:customer_card.exp_month, exp_year:customer_card.exp_year}
              ) 
              puts charge.inspect 
            end 
          gap_days = order.gap_days.to_i
          order.last_delivery_date = Date.today
          if gap_days > 0
            order.next_delivery_date = Date.today+ gap_days.days
          else
            order.next_delivery_date = Date.today+ 1.months
          end  
          order.save 
        rescue Stripe::CardError => e  
          # Since it's a decline, Stripe::CardError will be caught
          body = e.json_body
          err  = body[:error] 
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
          puts "inside error page1=#{@errors.inspect}"
        rescue => e
          # Something else happened, completely unrelated to Stripe
          @errors = e.message  
          puts "inside error page2=#{@errors.inspect}"
        end     
     end
  end 
   
end
