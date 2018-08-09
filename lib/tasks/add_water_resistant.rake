namespace :hair do
  
  task :wr => :environment do
       p = Product.new(:description=>"Water Resistant Spray", :product_code=>2092,:price=>2995,:weight=>10, :product_type=>"normal", :sku=>713807586799)
       puts p.valid?
       puts p.errors.inspect
       p.save
  end
   
 
end
