class RemoveStampsFromOrders < ActiveRecord::Migration
  def change
    remove_column :orders, :tracking_number
    remove_column :orders, :stamps_tx_id
    remove_column :orders, :shipping_label_url
  end
end
