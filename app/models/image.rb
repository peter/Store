class Image < ActiveRecord::Base
  belongs_to :has_image, :polymorphic => true
  
  has_attached_file :image,
    :styles => { :medium => "300x300>", :thumb => "100x100>" },
    :url => "/files/:rails_env/:attachment/:id/:style/:filename"
  
  def dom_id
    "image-#{id}"
  end
end
