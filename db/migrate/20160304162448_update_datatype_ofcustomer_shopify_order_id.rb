class UpdateDatatypeOfcustomerShopifyOrderId < ActiveRecord::Migration
  def change
    change_column :orders, :shopify_order_id, :bigint 
  end
end
