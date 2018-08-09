namespace :hair do

  task :value_pack => :environment do 
     
    Product.find_or_create_by(:description=>"Value Pack 2", :price=>7600, :sku=>66666, :product_code=>2092, :weight=>2.2, :product_type=>"normal", :shipping_price=>625)
    Product.find_or_create_by(:description=>"Value Pack 3", :price=>11400, :sku=>66666, :product_code=>2092, :weight=>2.2, :product_type=>"normal", :shipping_price=>625)
    Product.find_or_create_by(:description=>"Value Pack 4", :price=>15200, :sku=>66666, :product_code=>2092, :weight=>2.2, :product_type=>"normal", :shipping_price=>625)
    Product.find_or_create_by(:description=>"Value Pack 5", :price=>19000, :sku=>66666, :product_code=>2092, :weight=>2.2, :product_type=>"normal", :shipping_price=>625)
    Product.find_or_create_by(:description=>"Combo Pack", :price=>7600, :sku=>66666, :product_code=>2092, :weight=>2.2, :product_type=>"normal", :shipping_price=>625)
    
  end 

end