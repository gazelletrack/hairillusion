class CreateProducts < ActiveRecord::Migration
  def change
    create_table :products do |t|
      t.string :product_code, null: false
      t.integer :price, null: false
      t.string :description, null: false

      t.timestamps
    end
  end
end
