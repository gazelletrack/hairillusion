namespace :hair do
  
  task :create_fibre_hold => :environment do
       p = Product.new(:description=>"Hair Illusion Fiber Hold Spray", :product_code=>2092,:price=>1995,:weight=>10)
       puts p.valid?
       puts p.errors.inspect
       p.save
  end
   
 
end
