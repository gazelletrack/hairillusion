   
namespace :hair do 
  desc 'generate orders rake started'
  task :co => :environment do
    sql = "select c.id from orders o
      left join customers c on c.id = o.orderer_id 
      where o.parent_order_id is null and o.order_type ='recurrent' and (c.email!='noe@e.com' and c.email !='noemail@noemail.com') and o.cancelled=false and o.last_delivery_date < '2016-06-07' and o.first_delivery_date > '2016-02-07'"
       
      emails = Order.find_by_sql sql    
      customer_ids = emails.collect(&:id) 
      customers = Customer.where("id in (?)",customer_ids).order("id asc") 
      
      customers.each do |c| 
        puts c.id
        if c
          c.send_login_details  
        end
        
      end
  end 
   
end

