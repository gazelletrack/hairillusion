class CreateShipments < ActiveRecord::Migration
  def change
    create_table :shipments do |t|
      t.timestamps
    end

    add_column :orders, :shipment_id, :integer
    add_index :orders, :shipment_id
    remove_column :orders, :shipped_at
  end
end
