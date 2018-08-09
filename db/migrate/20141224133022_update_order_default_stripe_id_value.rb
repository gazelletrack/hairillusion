class UpdateOrderDefaultStripeIdValue < ActiveRecord::Migration
def change
    change_column :orders, :stripe_id, :string, :null => true
  end
end
