class Cart < ActiveRecord::Base
  serialize :content
  
  def add_product!(product)
    self.content ||= {}
    debugger
    content[product.id] ||= 0
    content[product.id] +=1
    save!
  end
end
