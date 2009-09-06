class AddActsAsTreeToContent < ActiveRecord::Migration
  def self.up
    add_column :contents, :parent_id, :integer
    add_column :contents, :order, :integer
  end

  def self.down
    remove_column :contents, :order
    remove_column :contents, :parent_id
  end
end
