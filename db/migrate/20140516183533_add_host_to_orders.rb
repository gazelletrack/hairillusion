class AddHostToOrders < ActiveRecord::Migration
  def change
    add_column :orders, :host, :string
  end
end
