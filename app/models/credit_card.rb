class CreditCard
  include ActiveModel::Model
  
  attr_accessor :name, :number, :cvc, :exp_month, :exp_year
  
  validates :name, presence: true
  validates :number, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 100000000000000, less_than_or_equal_to: 9999999999999999, message: "Please enter valid card number" }
  validates :cvc, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 0, less_than_or_equal_to: 9999, message: "Please enter valid cvc"  }
  validates :exp_month, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: 1, less_than_or_equal_to: 12, message: "Please enter valid month/year"  }
  validates :exp_year, presence: true, numericality: { only_integer: true, greater_than_or_equal_to: Time.now.year, message: "Please enter valid month/year"  }
  
  def initialize(attributes = {})
    attributes.each do |name, value|
      send("#{name}=", value)
    end
  end
  
  def persisted?
    false
  end
end
