class CreateDistributors < ActiveRecord::Migration
  def change
    create_table :distributors do |t|
      t.string :email, null: false
      t.string :password_digest, null: false
      t.boolean :require_password_reset, default: true

      t.string :company_name, null: :false
      t.string :first_name, null: :false
      t.string :last_name, null: :false
      t.string :tax_id, null: false
      t.string :phone, null: false
      t.string :address1, null: false
      t.string :address2
      t.string :city, null: false
      t.string :state, null: false
      t.string :zip, null: false
      t.boolean :approved, null: false, default: false
      t.integer :price, null: false, default: 5995
      t.string :stripe_id

      t.timestamps
    end
  end
end
