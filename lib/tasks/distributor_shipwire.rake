require 'rest-client'
require 'json'

namespace :hair do

  task :distributor_shipwire_orders => :environment do
    puts "shipwire rake started"
    Shipwire.configure do |config|
      config.username = "support@hairillusion.com"
      config.password = "ZZZack!!!"
      config.endpoint = URI::encode('https://api.shipwire.com')
    end
    
    Order.send_sipwire_rake_started
    orders = Order.find_by_sql "select o.* from orders o 
              left join distributors c on c.id = o.orderer_id
              where o.orderer_type='Distributor' and o.shipment_id is null and o.cancelled = false and 
              o.created_at > '2016-05-01'" 
    puts orders.size
     
    orders.each do |order|
      begin
        #get information
        order_id = order.id
        
        #get  items
        items = order.order_items
        #get production information
  
        #get customer information
        customer = Distributor.find_by(id: order.orderer_id) 
        if customer
        #get general order information
        #for each order make POST request
  
        #now create shipwire order
  
        #items generation
        order_items = []
        items.each do |item|
          puts item.product.sku
          order_items << { :sku => item.product.sku, :quantity => item.quantity, :commercialInvoiceValue => item.price.to_f / 100, :commercialInvoiceValueCurrency => 'USD'}
        end
        
        puts order_items.inspect
        
        #servicelevelcode and carriercode
        serviceLevel = 'E-INTL'
        carrierCode = 'USPS FCI'
        #check if  not domestsic 
        
        serviceLevel = 'GD' if customer.country == 'US' || customer.country == 'us'
        carrierCode = 'USPS FC' if customer.country == 'US' || customer.country == 'us'
        
        puts order.inspect
        carrierCode = order.shipping_code unless order.shipping_code.blank? 
                
        shipwire_order = {
          :orderNo      => "##{order_id}_11LIVE123",
          :externalId   => "#{order_id}_11LIVE123",
          :processAfterDate => nil,
          # List of items ordered
          :items => order_items,
          :options => {
            # Specify one of warehouseId, warehouseExternalId, warehouseRegion, warehouseArea
            :warehouseId          => nil,
            :warehouseExternalId  => nil,
            :warehouseRegion      => nil,
            :warehouseArea        => nil,
            # Service requested for this order
            :serviceLevelCode     => serviceLevel,
            # Delivery carrier requested for this order
            :carrierCode          => carrierCode,
            # Was "Same Day" processing requested ?
            :sameDay  => 'NOT REQUESTED',
            # Used to assign a pre-defined set of shipping and/or customization preferences on an order.
            # A channel must be defined prior to order creation for the desired preferences to be applied.
            # Please contact us if you believe your application requires a channel.
            :channelName => nil,
            :forceDuplicate => 0,
            :forceAddress   => 00,
            :carrierAccountNumber => nil,
            :referrer             =>  'Hair Illusion Ruby App',
            :affiliate      => nil,
            :currency => 'USD',
            # Specifies whether the items to be shipped can be split into two packages if needed
            :canSplit => 0,
            # Set a manual hold
            :note => nil,
            :hold    => 0,
            # A discount code
            :holdReason    => nil,
            :discountCode    => "FREE STUFF",
            :server    => "Production"
          },
          # Shipping source
          :shipFrom    => { :company => 'Hair Illusion'},
          :shipTo    => {
            # Recipient details
            :email    => customer.email,
            :name    => customer.first_name + " " + customer.last_name,
            :company    => "",
            :address1    => customer.address1,
            :address2    => customer.address2,
            :address3    => "",
            :city        => customer.city,
            :state       => customer.state,
            :postalCode  => customer.zip,
            :country    =>  customer.country,
            :phone      => '',
            # Specifies whether the recipient is a commercial entity. 0 = no, 1 = yes
            :isCommercial    => 0,
            # Specifies whether the recipient is a PO box. 0 = no, 1 = yes
            :isPoBox    => 0
          },
          # Invoiced amounts (for customs declaration only)
          :commercialInvoice    => {
            # Amount for shipping service
            :shippingValue    => 8.95,
            # Amount for insurance
            :insuranceValue    => 0,
            :additionalValue    => 0,
            # Currencies to interpret the amounts above
            :shippingValueCurrency    => "USD",
            :insuranceValueCurrency    => "USD",
            :additionalValueCurrency    => "USD"
          }
          # Message to include in package
        }
        #on successful, add entries... 
        #p shipwire_order.to_json
        new_order = Shipwire::Orders.new
        
        response = new_order.create(shipwire_order)  
        p response.inspect
        if(response.body['status'] == 200)
          #if successful, mark as 'shipped'
          unless response.validation_errors.present? && response.validation_errors.any? 
            OrderDelivery.create(:order_id => order_id, :delivered_date=>Date.today)
            shipment = Shipment.create(:created_at=> Time.now)
            order.update_attribute(:shipment_id, shipment.id)
            order.update_attribute(:last_delivery_date, Date.today) 
          else 
            OrderMailer.send_shipwire_error(response.validation_errors,order.id).deliver!
          end
        #add shipped entry
        else 
          OrderMailer.send_shipwire_error(response.error_report,order.id).deliver!
        end  
       else
         puts "customer not found--#{order.orderer_id}"
      end
      rescue
        OrderMailer.send_shipwire_error("exception during rake task of shipwire order creation",order.id).deliver!
        next
      end
    end
  end
end