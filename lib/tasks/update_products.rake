namespace :hair do
  
  task :update_price => :environment do
        products = Product.all
      products.each do |product|
      #product.price = 4495
      product.update_attribute(:price, 5995)
      product.update_attribute(:weight, 3.3)
      puts product.inspect
      product.save
    end
  end
  
  
  task :clear_shopify_details => :environment do
    Customer.all.each do |c|
      c.destroy
    end
    
    Order.all.each do |c|
      c.destroy
    end 
    
  end
 
end
