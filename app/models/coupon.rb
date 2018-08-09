class Coupon < ActiveRecord::Base
  
  validates :name, presence: true
  validates :discount_type, presence: true
  validates :discount_value, presence: true
  
  validates :name, uniqueness: true
  
end
