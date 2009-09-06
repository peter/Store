class RemoveMenuBuilderField < ActiveRecord::Migration
  def self.up
    remove_column :contents, :menu_builder
  end

  def self.down
    add_column :contents, :menu_builder, :string
  end
end
