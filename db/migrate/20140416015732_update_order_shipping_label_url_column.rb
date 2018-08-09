class UpdateOrderShippingLabelUrlColumn < ActiveRecord::Migration
  def change
    change_column :orders, :shipping_label_url, :text
  end
end
