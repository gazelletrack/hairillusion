class DistributorProductPrice < ActiveRecord::Base
  
  belongs_to :distributor 
  belongs_to :distributor_product
  
end
