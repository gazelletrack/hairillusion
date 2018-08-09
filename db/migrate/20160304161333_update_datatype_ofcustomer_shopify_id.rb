class UpdateDatatypeOfcustomerShopifyId < ActiveRecord::Migration
  def change
    change_column :customers, :shopify_customer_id, :bigint 
  end
end
