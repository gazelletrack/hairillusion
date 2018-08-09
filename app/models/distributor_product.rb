class DistributorProduct < ActiveRecord::Base
  
  def description
    return self.name
  end
  
end
