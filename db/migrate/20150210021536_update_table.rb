class UpdateTable < ActiveRecord::Migration
  
  def change 
    execute("ALTER TABLE order_items CONVERT TO CHARACTER SET utf8;")
    execute("ALTER TABLE customers CONVERT TO CHARACTER SET utf8;") 
    execute("ALTER TABLE orders CONVERT TO CHARACTER SET utf8;") 
    execute("ALTER TABLE distributors CONVERT TO CHARACTER SET utf8;") 
  end
  
end
