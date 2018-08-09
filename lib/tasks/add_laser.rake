namespace :hair do
  
  task :add_laser => :environment do
      pp = Product.where(:description=>"Laser Comb").first
      unless pp
       p = Product.new(:description=>"Laser Comb", :product_code=>2092,:price=>24900,:weight=>10, :product_type=>"normal", :sku=>713807586829)
       puts p.valid?
       puts p.errors.inspect
       p.save
       end
  end
   
 
end
