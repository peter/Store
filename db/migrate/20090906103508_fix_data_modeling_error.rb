class FixDataModelingError < ActiveRecord::Migration
  def self.up
   remove_column :menus, :content_id 
    add_column :contents, :menu_id, :integer  
  end

  def self.down
    remove_column :contents, :menu_id
    add_column :menus, :content_id, :integer
  end
end
