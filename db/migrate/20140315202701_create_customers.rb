class CreateCustomers < ActiveRecord::Migration
  def change
    create_table :customers do |t|
      t.string :first_name, null: :false
      t.string :last_name, null: false
      t.string :email, null: false 
      t.string :address1, null: false
      t.string :address2
      t.string :city, null: false
      t.string :state, null: false
      t.string :zip, null: false

      t.string :stripe_id, null: false

      t.timestamps
    end

    add_index :customers, :stripe_id, unique: true
  end
end
