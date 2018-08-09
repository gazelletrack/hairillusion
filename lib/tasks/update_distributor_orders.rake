namespace :hair do  
  
  task :update_shopify_orders => :environment do 
    shop_url = "https://a98b179d72117d149e44ae83796e4c64:b62b5da657f75898e1d45eb6a6e0e247@hair-illusion-llc.myshopify.com/admin"
    ShopifyAPI::Base.site = shop_url

    orders = ShopifyAPI::Order.all
    orders.each do |o|
      if o.landing_site.include?('hairillusion.net')
        host = "hairillusion.net"
      elsif ( o.landing_site.include?('hairisthere.com') || o.id == 381870669)
        host = "hairisthere.com"
      elsif ( o.landing_site.include?('hairillusion.com') || o.landing_site.include?('Fhairillusion%3A3000') )
        host = "hairillusion.com"
      elsif o.landing_site.include?('buyhairillusion.com')
        host = "buyhairillusion.com"
      elsif o.landing_site.include?('gethairillusion.com')
        host = "gethairillusion.com"
      elsif o.landing_site.include?('hairillusion4you.com')
        host = "hairillusion4you.com"
      end
 
      order = Order.find_by_shopify_order_id o.id
      order.host = host
      order.save
    end 
    
    DistributorOrder.all.each do |oo|
      oo.destroy
    end
    
    orders = Order.all
    orders.each do |order| 
      host = order.host
      host.sub! 'www.', '' 
      distributor = DomainDistributor.where("domain LIKE '%#{host}%'").first 
      distributor_order = DistributorOrder.new(:distributor_id=>distributor.id, :order_id=>order.id, :created_at=>order.created_at)
      distributor_order.save
    end
  end
  
end