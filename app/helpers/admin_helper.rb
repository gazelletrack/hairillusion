module AdminHelper
  
  def get_order_product_name(order)
    name = ""  
    order.order_items.each do |item|
      if name.length>0
        name = name + ", "
      end 
      name = name + "hairillusion #{item.try(:product).try(:description)}"
    end
    return name
  end
  
  def get_order_quantity(order) 
    quantity = order.try(:order_items).try(:size).to_i
    return quantity
  end
  
  def get_order_amount(order) 
    amount = order.order_items.map(&:price).sum 
    amount = number_to_currency(amount / 100.0)
    return amount
  end
  
  def get_total_quantity(distributor)
    quantity = 0
    distributor.distributor_orders.each do |d_o|
      quantity = quantity + d_o.order_items.size
    end
    return quantity
  end
  
  def get_total_price(distributor)
    price = 0
    distributor.distributor_orders.each do |d_o| 
      price = quantity + d_o.order_items.size
    end
    return price
  end
  
  def state_code(forum)
    unless forum.state.nil?
      return forum.state
    else
      return 'US'
    end
  end

end