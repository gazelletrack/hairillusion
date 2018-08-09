namespace :hair do

  task :del_orders => :environment do 
    orders = Order.where("id > 0 and parent_order_id is null and order_type ='recurrent' and next_delivery_date < '2016-10-01' and cancelled=false and hc_order=true").order("id asc")
    
    
    
    orders.each do |s|
      s.cancelled = true
      s.save
    end


    orders = Order.where("id > 0 and parent_order_id is null and order_type ='recurrent' and next_delivery_date < '2016-10-01' and cancelled=false and hc_order=false").order("id asc")
    
    orders.each do |s|
      s.cancelled  = true
      s.save
    end

  end
  
end