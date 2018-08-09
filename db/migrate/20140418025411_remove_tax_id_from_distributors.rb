class RemoveTaxIdFromDistributors < ActiveRecord::Migration
  def change
    remove_column :distributors, :tax_id
  end
end
