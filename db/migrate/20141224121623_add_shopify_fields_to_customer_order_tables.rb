class AddShopifyFieldsToCustomerOrderTables < ActiveRecord::Migration
  def change
    add_column :customers, :shopify_customer_id, :integer
    add_column :orders, :shopify_order_id, :integer
  end
end
