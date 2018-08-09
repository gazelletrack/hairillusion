class AddNameAddressToForum < ActiveRecord::Migration
  def change 
    add_column :forums, :name, :string
    add_column :forums, :address, :text
  end
end
