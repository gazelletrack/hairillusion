class CreateForums < ActiveRecord::Migration
  def change
    create_table :forums do |t|
      t.string :subject
      t.text :content
      t.boolean :approved, :deafult=>false 
      t.timestamps
    end
  end
end
