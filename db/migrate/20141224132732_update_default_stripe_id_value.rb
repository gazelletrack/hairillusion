class UpdateDefaultStripeIdValue < ActiveRecord::Migration
  def change
    change_column :customers, :stripe_id, :string, :null => true
  end
end
