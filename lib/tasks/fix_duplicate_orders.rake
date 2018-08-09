namespace :hair do

  task :fix_dup_order => :environment do
    shopify_ids = Order.where("shopify_order_id is not null").collect(&:shopify_order_id)
    puts shopify_ids.size

#    puts shopify_ids.uniq.size
#{|x| x.shopify_order_id}
    uniq_ids = shopify_ids.uniq#{|x| x.shopify_order_id}

    uniq_ids.each do |id|
      orders = Order.where("shopify_order_id =?",id)
#puts orders.size
      if orders.size > 1
        orders.each_with_index do  |order, index|
#          puts index
          if index > 0
          order.destroy
puts order.id
          end
        end
      end
    end
  end

end
