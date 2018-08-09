class Product < ActiveRecord::Base
  has_many :order_items

  PRODUCT_CODE = {
    jet_black: 2092,
    black: 2093,
    dark_brown: 2094,
    brown: 2095,
    light_brown: 2096,
    brown: 2097,
    dark_blonde: 2098,
    blonde: 2099
  }

  validates :product_code, presence: true, inclusion: { in: PRODUCT_CODE.values, message: "%{value} is not a valid color" }
  validates :price, presence: true, numericality: { greater_than: 0 }
  validates :description, presence: true
end
