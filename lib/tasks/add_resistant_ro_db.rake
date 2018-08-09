namespace :hair do

  task :ro => :environment do  
    DistributorProduct.find_or_create_by(:name=>"Water Resistant Spray", :sku=>713807586799) 
  end 
  
  task :add_dp => :environment do  
    product = DistributorProduct.where(:name=>"Water Resistant Spray").first
    Distributor.find_each do |d|
      puts "..."
      distributor_product = DistributorProductPrice.where(:distributor_id=>d.id, :distributor_product_id=>product.id).first
      if distributor_product
        distributor_product.update_attribute(:price, 19.00)
      end
      #unless distributor_product
       # DistributorProductPrice.create(:distributor_id=>d.id, :distributor_product_id=>product.id, :price=>29.95)
      #end 
    end
    
  end 

end