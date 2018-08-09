require 'rest-client'
require 'json'

namespace :hair do

  task :ship_single_order => :environment do
    puts "shipwire rake started"
    Shipwire.configure do |config|
      config.username = "support@hairillusion.com"
      config.password = "ZZZack!!!"
      config.endpoint = URI::encode('https://api.shipwire.com')
    end
    
    Order.send_sipwire_rake_started
    orders = Order.find_by_sql "select o.id, o.orderer_id from orders o 
              left join customers c on c.id = o.orderer_id
              where o.id = 9005"

    puts orders.size
    
    orders.each do |order|
     # begin
     customer = Customer.find_by(id: order.orderer_id) 
        #get information
        order_id = order.id
  order_items = []
        #get  items
        puts order_id 
        items = order.order_items
        items.each do |item| 
          product = Product.find item.product_id 
          order_items << { :sku =>  product.sku, :quantity => item.quantity, :commercialInvoiceValue => item.price / 100, :commercialInvoiceValueCurrency => 'USD'}
        end
        #servicelevelcode and carriercode
        serviceLevel = nil
        #check if  not domestsic
        serviceLevel = 'GD' if customer.billing_country == 'US' || customer.billing_country == 'us'
        carrierCode = 'USPS FC' if customer.billing_country == 'US' || customer.billing_country == 'us'
        
        carrierCode = order.shipping_code unless order.shipping_code.blank? 
        
        puts carrierCode

        shipwire_order = {
          :orderNo      => "##{order_id}_LI11VE",
          :externalId   => "#{order_id}_LI11VE",
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
            order.update_attribute(:next_delivery_date, Date.today+(order.gap_days).days)
          else 
            OrderMailer.send_shipwire_error(response.validation_errors,order.id).deliver!
          end
        #add shipped entry
        else 
          OrderMailer.send_shipwire_error(response.error_report,order.id).deliver!
        end  
 
    end
  end
end