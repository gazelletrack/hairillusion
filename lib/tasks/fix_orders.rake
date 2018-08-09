namespace :hair do

  task :remove_non_orders => :environment do 
    
  #  orders = Order.where("shopify_order_id >=1347056129")
    # puts "#{orders.size} orders will be deleted"
   #  orders.each do |o|
  #     o.destroy
   #  end   
     
    DistributorOrder.all.each do |d|
      o = Order.where(:id=>d.order_id).first 
      if o.nil?
        puts "deletable do id-- #{d.id}"
        d.destroy 
      end
    end
  end 

end