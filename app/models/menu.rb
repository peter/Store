class Menu < ActiveRecord::Base
acts_as_tree :order => "name"
has_many :contents
validates_presence_of :name, :on => :create, :message => "can't be blank"
named_scope :top_level, :conditions => "parent_id IS NULL"

def padded_name
 ("-" * ancestors.size)<<name
end

end
