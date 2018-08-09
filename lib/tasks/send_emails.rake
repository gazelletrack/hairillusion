namespace :hair do
  desc 'generate orders rake started'
  task :email => :environment do
    sql = "select * from orders where id>0 and parent_order_id is null and order_type ='recurrent' and next_delivery_date < '2016-09-15' and cancelled=false and hc_order=true order by id asc limit 25"
    orders = Order.find_by_sql sql
    orders.each do |o| 
      if o.orderer_type= 'Customer'
        customer = Customer.find o.orderer_id
        if customer
         begin
          OrderMailer::user_notification(customer.email).deliver!
         rescue
           next
         end
        end
        puts "customer.email--#{o.id}"
      end
    end
  end

end

