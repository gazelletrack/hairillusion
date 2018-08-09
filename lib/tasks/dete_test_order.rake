namespace :hair do
  
  task :delete_test_order => :environment do
       order = Order.find 410
       puts order
       #order.destroy
       
  end
   
 
end
