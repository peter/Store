class Product < ActiveRecord::Base
  attr_accessor :image
  after_save :save_image
  
  validates_presence_of :name
  
  has_many :images, :as => :has_image
  has_many :comments
  has_many :orders, :through => :line_items
  
  private
  
  def save_image
    if image
      images.destroy_all
      images.create(:image => image)
    end
  end
end
