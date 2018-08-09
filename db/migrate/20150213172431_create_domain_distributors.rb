class CreateDomainDistributors < ActiveRecord::Migration
  def change
    create_table :domain_distributors do |t|
      t.string :name
      t.string :company_name
      t.string :email
      t.float :percentage
      t.string :phone
      t.text :address
      t.string :state
      t.string :country
      t.string :zip

      t.timestamps
    end
  end
end
