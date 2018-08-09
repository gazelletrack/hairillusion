require 'rest-client'
require 'json'

namespace :hair do

  task :shipwire_orders => :environment do
    puts "shipwire rake started"
    Shipwire.configure do |config|
      config.username = "support@hairillusion.com"
      config.password = "ZZZack!!!"
      config.endpoint = URI::encode('https://api.shipwire.com')
    end
    
    Order.send_sipwire_rake_started
    orders = Order.find_by_sql "select o.* from orders o 
              left join customers c on c.id = o.orderer_id
              where o.orderer_type='Customer' and o.paid=true and o.shipment_id is null and o.version_2_order = true and o.cancelled = false and o.created_at > '2016-05-05'"

    puts orders.size 
    puts orders.inspect
    
    orders.each do |order|
      begin
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
        puts order_id 
        
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
        
        ord = Order.find order_id
        if ord && ord.cancelled == false && ord.paid == true 
          shipwire_order = {
            :orderNo      => "##{order_id}_LIVE112211",
            :externalId   => "#{order_id}_LIVE1122111",
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
              if order.parent_order_id
                @parent_order = Order.find order.parent_order_id
                if (@parent_order)
                  gap_days = @parent_order.gap_days.to_i
                  if gap_days >0
                    @parent_order.next_delivery_date = Date.today + gap_days.days
                  else
                     @parent_order.next_delivery_date = Date.today + 1.months 
                  end
                  @parent_order.last_delivery_date = Date.today
                  @parent_order.save!
                else
                  @parent_order
                end
              else
                #for first time
                gap_days = order.gap_days
                if gap_days >0
                  order.next_delivery_date = Date.today + gap_days.days
                else
                  order.next_delivery_date = Date.today + 1.months
                end
                order.save!
              end 
            else 
              OrderMailer.send_shipwire_error(response,order.id).deliver!
            end
          #add shipped entry
          else 
            OrderMailer.send_shipwire_error(response,order.id).deliver!
          end  
      end
      rescue => error
      OrderMailer.send_shipwire_error("exception during rake task of shipwire order creation--#{error}",order.id).deliver!
       next
      end 
    end
  end
end