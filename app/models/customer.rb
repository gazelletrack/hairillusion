class Customer < ActiveRecord::Base
  extend GridTable

  has_many :orders, as: :orderer, dependent: :destroy

  validates :first_name, presence: true
  validates :last_name, presence: true
  validates :email, presence: true, format: { with: /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i }
  validates :address1, presence: true
  validates :city, presence: true
  validates :country, presence: true
  validates :state, presence: true
#  validates :zip, presence: true#, numericality: true, format: { with: %r{\d{5}(-\d{4})?}, message: "should be 12345 or 12345-1234" }

  grid_table_control :created_at
  grid_table_control :first_name
  grid_table_control :last_name
  grid_table_control :email
  grid_table_control :city
  grid_table_control :state

  def name
    "#{first_name} #{last_name}"
  end
end
