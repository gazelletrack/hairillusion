class AddDomainToForum < ActiveRecord::Migration
  def change
    add_column :forums, :domain_name, :string
  end
end
