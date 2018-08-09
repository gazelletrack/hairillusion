class CreateDistributorOrders < ActiveRecord::Migration
  def change
    create_table :distributor_orders do |t|
      t.integer :distributor_id
      t.integer :order_id

      t.timestamps
    end
  end
end
