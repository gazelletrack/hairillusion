class Shipment < ActiveRecord::Base
  extend GridTable
  
  has_many :orders, dependent: :nullify

  grid_table_control :created_at
end
