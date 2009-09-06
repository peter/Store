class CreateCarts < ActiveRecord::Migration
  def self.up
    create_table :carts do |t|
      t.text :content

      t.timestamps
    end
  end

  def self.down
    drop_table :carts
  end
end
