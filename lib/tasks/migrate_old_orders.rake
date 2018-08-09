namespace :hair do
  
  task :migrate_domain_orders => :environment do
    orders = Order.all
      orders.each do |order|
        
       if order.host.include?('hairillusion.net') 
          distributor = DomainDistributor.where(:domain=>"hairillusion.net").first
          if distributor 
            distributor_order = DistributorOrder.new(:distributor_id=>distributor.id, :order_id=>order.id, :created_at=>order.created_at)
            distributor_order.save
          end 
        elsif order.host.include?('buyhairillusion.com')  
          distributor = DomainDistributor.where(:domain=>"buyhairillusion.com").first
          if distributor
            distributor_order = DistributorOrder.new(:distributor_id=>distributor.id, :order_id=>order.id, :created_at=>order.created_at)
            distributor_order.save
          end
        elsif order.host.include?('gethairillusion.com')  
          distributor = DomainDistributor.where(:domain=>"gethairillusion.com").first
          if distributor
            distributor_order = DistributorOrder.new(:distributor_id=>distributor.id, :order_id=>order.id, :created_at=>order.created_at)
            distributor_order.save
          end 
        elsif order.host.include?('hairillusion.com')  
          distributor = DomainDistributor.where(:domain=>"hairillusion.com").first
          if distributor
            distributor_order = DistributorOrder.new(:distributor_id=>distributor.id, :order_id=>order.id, :created_at=>order.created_at)
            distributor_order.save
          end 
        else  
          DomainDistributor.all.each do |d| 
            if order.host.include?(d.domain)  
              distributor_order = DistributorOrder.new(:distributor_id=>d.id, :order_id=>order.id, :created_at=>order.created_at)
              distributor_order.save
              host = "#{d.domain}-shopify"  
              OrderMailer.send_order_email(distributor_order.distributor_id, distributor_order.order_id).deliver
            end 
          end
        end   
    end
  end
    
end
