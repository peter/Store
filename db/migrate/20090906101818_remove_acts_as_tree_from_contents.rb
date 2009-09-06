class RemoveActsAsTreeFromContents < ActiveRecord::Migration
  def self.up
    remove_column :contents, :order
    remove_column :contents, :parent_id
  end

  def self.down
    add_column :contents, :parent_id, :integer
    add_column :contents, :order, :integer
  end
end
