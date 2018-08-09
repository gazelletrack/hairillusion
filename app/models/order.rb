class Order < ActiveRecord::Base
  extend GridTable

  attr_accessor :order_id 
  has_many :distributor_orders, foreign_key: "order_id"  

  belongs_to :orderer, polymorphic: true
  belongs_to :shipment
  has_many :order_items, dependent: :destroy

  accepts_nested_attributes_for :order_items

  grid_table_control :id
  grid_table_control :created_at
  grid_table_control :orderer
  grid_table_control :host

  scope :unshipped, -> { where(shipment_id: nil).where(refunded_at: nil) }
  
  def order_source
    if self.host.blank?
      if self.agent_id
        agent = Agent.find self.agent_id
        return agent.name if agent
        return "" 
      end
    else
      return self.host
    end
    return "" 
  end
  
  def total
    total = order_items.collect { |oi| oi.total }.inject { |sum, x| sum + x }

    total + shipping_cost
  end
  
  def total_price
    return 0 if order_items.nil?
    total = order_items.collect { |oi| oi.total }.inject { |sum, x| sum + x } 
    return 0 if total.nil?
    total = total/100.00
  end
  
  def total_commission_price
    hold_product = Product.where(:description=>"Hair Illusion Fiber Hold Spray").last    
    order_items_list = self.order_items.delete_if {|item| item.product_id == hold_product.id } unless self.order_items.empty?  
    if order_items_list.nil? || order_items_list.size == 0
      total = 0
    else
      total = order_items_list.collect { |oi| oi.total }.inject { |sum, x| sum + x } 
      total = total/100.00
    end 
  end
  
  def total_price_for_email
    price = 0
    total = self.total_price rescue 0
    shipping = self.shipping_price.to_f rescue 0
    process_handling_price = self.process_handling_price.to_f rescue 0
    discount = self.discount.to_f rescue 0
    
    return (total+ shipping+ process_handling_price-discount)
  end

  def total_quantity
    order_items.collect { |oi| oi.quantity }.inject { |sum, x| sum + x } || 0
  end

  def description
    order_items.collect { |oi| "#{oi.product.description} x#{oi.quantity}" if oi.quantity > 0 }.join(', ')
  end

  # total weight in oz
  def total_weight
    order_items.collect { |oi| oi.weight }.inject { |sum, x| sum + x } || 0
  end

  def shipping_cost
    total = 0

    # Medium priority flat rate $11.30 for up to 30 bottles.
    medium = 1130

    # Large priority flat rate $15.80 for 30-50 bottles.
    large = 1580

    if orderer_type == Distributor.name
      quantity = total_quantity
      total = (quantity / 50) * large

      if (quantity % 50) <= 30
        total = total + medium
      else
        total = total + large
      end
    end

    total
  end

  def mail_class
    'priority'
  end

  def mail_piece
    if total_quantity <= 30
      'flat rate priority box'
    else
      'large flat rate priority box'
    end
  end

  def stripe_charge
    Stripe::Charge.retrieve(self.stripe_id)
  end

  def prepare_for_shipping
    results = []

    order = shipping_order(self)

    self.order_items.each do |order_item|
      if (order.total_quantity + order_item.quantity <= 50)
        order.order_items<< OrderItem.new(product: order_item.product, price: order_item.price, quantity: order_item.quantity)
      else
        partial_quantity = 50 - order.total_quantity

        if partial_quantity > 0
          order.order_items<< OrderItem.new(product: order_item.product, price: order_item.price, quantity: partial_quantity)
        end

        results<< order
        order = shipping_order(self)

        order_item_quantity = order_item.quantity
        order_item_quantity -= partial_quantity

        while order_item_quantity > 0
          if order_item_quantity > 50
            order.order_items<< OrderItem.new(product: order_item.product, price: order_item.price, quantity: 50)
            order_item_quantity -= 50

            results<< order
            order = shipping_order(self)
          else
            order.order_items<< OrderItem.new(product: order_item.product, price: order_item.price, quantity: order_item_quantity)
            order_item_quantity = 0
          end
        end
      end
    end

    if order.total_quantity > 0
      results<< order
    end

    results
  end
  
  def get_total_shipping(shipping_price, value_pack_shipping)
    price = 0.0
    product_count = 0
    self.order_items.each do |s|
      product = Product.find s.product_id 
      if product && product.description != "Value Pack 1" && product.description != "Value Pack 2" && product.description != "Value Pack 3" && product.description != "Value Pack 4" && product.description != "Value Pack 5" && product.description != "Combo Pack" && product.description != "Mirror" && product.description != "Optimizer" && product.description != "Hair Illusion Fiber Hold Spray"
        product_count+= s.quantity
      end
    end 
    if product_count > 1
      return shipping_price+ value_pack_shipping + (product_count-1)
    else
      return value_pack_shipping
    end 
  end

  def get_shipping_cost
    return 0 if self.order_items.nil? 
    tax = self.order_items.collect { |oi| oi.tax.to_i }.inject { |sum, x| sum + x } 
    return 0 if tax.nil?
    total = tax/100.00
  end
    
  def total_price
    return 0 if order_items.nil?
    total = order_items.collect { |oi| oi.total }.inject { |sum, x| sum + x } 
    return 0 if total.nil?
    total = total/100.00
  end
  
  def can_ship_from_amazon
    ship_from_fba = true
    
     if self.orderer && self.orderer.billing_country == "US" && ( self.shipping_code == "Expedited" || self.shipping_code == "Standard" || self.shipping_code == "Priority" )
     self.order_items.each do |s|
        ship_from_fba = false if s.amazon_sku.blank? || s.amazon_sku.nil?
      end
    else
      return false
    end
    return ship_from_fba
  end  

  private
  def shipping_order(order)
    @sub_id ||= 'a'

    order = Order.new(
      order_id: "%08d" % order.id + "#{@sub_id}",
      created_at: order.created_at,
      orderer: order.orderer
    )

    @sub_id = @sub_id.succ

    return order
  end 
  
end
