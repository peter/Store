class Order < ActiveRecord::Base
  validates_numericality_of :customer_id, :on => :create, :message => "is not a number"
  
  has_many :products, :through => :line_items
  has_many :line_items  
  
  belongs_to :customer
end
