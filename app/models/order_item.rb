class OrderItem < ActiveRecord::Base
  belongs_to :order
  belongs_to :product, polymorphic: true

  validates :quantity, numericality: { greater_than: 0, integer_only: true }
  validates :price, presence: true, numericality: { greater_than: 0 }

  def total
    self.price * self.quantity
  end

  def handling_fee
    if self.order.order_type == "recurrent"
      #return 
    end
  end

  def weight
    (quantity.to_f * product.weight).round(2)
  end
  
  def product_name
    product = Product.find self.product_id
    return product.description if product
    return ""
  end
  
  def amazon_sku
    product = Product.find self.product_id
    return product.amazon_sku if product
    return ""
  end
  
end
