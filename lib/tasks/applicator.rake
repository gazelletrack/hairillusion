namespace :hair do
  
  task :add_6g => :environment do
      pp = Product.where(:description=>"Spray Applicator").first
      unless pp
       p = Product.new(:description=>"Spray Applicator", :product_code=>2092,:price=>4495,:weight=>10, :product_type=>"normal", :sku=>706098647300)
       puts p.valid?
       puts p.errors.inspect
       p.save
       end

      pp = Product.where(:description=>"Black 6g").first
      unless pp
       p = Product.new(:description=>"Black 6g", :product_code=>2092,:price=>1495,:weight=>10, :product_type=>"normal", :sku=>706098647669)
       puts p.valid?
       puts p.errors.inspect
       p.save
       end
       

  end
   
 
end
