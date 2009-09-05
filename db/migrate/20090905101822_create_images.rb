class CreateImages < ActiveRecord::Migration
  def self.up
    create_table :images do |t|
      t.integer :has_image_id # polymorphic association
      t.string :has_image_type # polymorphic association
      t.string :image_file_name # paperclip
      t.string :image_content_type # paperclip
      t.integer :image_file_size # paperclip
      t.timestamps
    end
  end

  def self.down
    drop_table :images
  end
end
