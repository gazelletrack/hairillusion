require 'rest-client'
require 'json'
require 'shipwire'    

namespace :hair do

  task :sr => :environment do

    puts "shipwire rake started"
    Shipwire.configure do |config|
      config.username = "support@hairillusion.com"
      config.password = "ZZZack!!!"
      config.endpoint = URI::encode('https://api.shipwire.com')
    end

    orders = Order.where("id=8330").order("id desc").limit(1)
    
    puts orders.size 
    
    orders.each do |order|
    #get information
      order_id = order.id

      #get  items
      items = order.order_items
      #get production information

      #get customer information
      customer = Customer.find_by(id: order.orderer_id)
      #get general order information
      #for each order make POST request

      #now create shipwire order

      #items generation
      order_items = []
      puts customer.billing_zip

      items.each do |item| 
        product = Product.find item.product_id
        order_items << { :sku =>  product.sku, :quantity => item.quantity, :commercialInvoiceValue => item.price / 100, :commercialInvoiceValueCurrency => 'USD'}
      end
  
          items = order_items 
          address    = {
            # Recipient details
            :email    => customer.email,
            :name    => customer.billing_first_name + " " + customer.billing_last_name,
            :company    => "",
            :address1    => customer.billing_address1,
            :address2    => customer.billing_address2,
            :address3    => "",
            :city        => customer.billing_city,
            :state       => customer.billing_state,
            :postalCode  => customer.billing_zip,
            :country    =>  customer.billing_country,
            :phone      => '',
            # Specifies whether the recipient is a commercial entity. 0 = no, 1 = yes
            :isCommercial    => 0,
            # Specifies whether the recipient is a PO box. 0 = no, 1 = yes
            :isPoBox    => 0
          } 
          
        
        payload = {options: {  currency: "USD", groupBy: "all" },
          order: {
          shipTo: address,
          items: items
        }} 
        
        response = Shipwire::Rate.new.find(payload)  
         
         
        options = response.body['resource']['rates'][0]['serviceOptions'] rescue [] 
        carriers = []
        options.each do |rate|
          obj = rate['shipments'][0]
          puts "..XXXXXXXXXXX....."    
          
          carriers << { name: obj['carrier']['description'], delever_min_date: obj['expectedDeliveryMinDate'],delever_max_date: obj['expectedDeliveryMinDate'], amount: obj['cost']['amount'], currency: obj['cost']['currency'] } 
        end 
        puts carriers.inspect
      end 

  end

end