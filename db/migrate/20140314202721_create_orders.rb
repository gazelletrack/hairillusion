class CreateOrders < ActiveRecord::Migration
  def change
    create_table :orders do |t|
      t.integer :orderer_id, null: false
      t.string  :orderer_type, null: false

      t.string :destription

      t.string :stripe_id, null: false

      t.string :tracking_number
      t.string :stamps_tx_id
      t.string :shipping_label_url
      t.date   :shipped_at
      t.datetime :refunded_at

      t.timestamps
    end

    add_index :orders, [:orderer_id, :orderer_type]
    add_index :orders, :stripe_id, unique: true
  end
end
