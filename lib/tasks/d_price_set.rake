namespace :hair do

  task :set_dp => :environment do 
    distributor_product_prices = DistributorProductPrice.all
    puts "rake started"
    distributor_product_prices.each do |p|
      
      if p.price == 19.95
        p.price = 22.50
        p.save
      end
      if p.price == 12.95
        p.price = 15.00
        p.save
      end
     
    end
     puts "rake finished"
  end
  
end

