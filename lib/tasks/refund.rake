

namespace :hair do
  
  task :refund => :environment do 
              
   puts "**************************---here starts updated rake****************************"
    shop_url = "https://a98b179d72117d149e44ae83796e4c64:b62b5da657f75898e1d45eb6a6e0e247@hair-illusion-llc.myshopify.com/admin"
    ShopifyAPI::Base.site = shop_url  
 
    order = ShopifyAPI::Order.find(3240886209)
    puts order.inspect
    
    refund = nil#order.cancel(email: false, restock: true) 
      
      puts refund.inspect
    
  end 
 
end
