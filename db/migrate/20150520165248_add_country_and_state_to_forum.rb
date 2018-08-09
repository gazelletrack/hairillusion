class AddCountryAndStateToForum < ActiveRecord::Migration
  def change
    add_column :forums, :country, :string
    add_column :forums, :state, :string
  end
end
