class AddDomainToDomainDistributor < ActiveRecord::Migration
  def change
    add_column :domain_distributors, :domain, :string
  end
end
