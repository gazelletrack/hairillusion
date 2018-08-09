class DistributorOrder < ActiveRecord::Base
  
  belongs_to :domain_distributor
  belongs_to :order 
  validates :order_id, uniqueness: true 
  
end
